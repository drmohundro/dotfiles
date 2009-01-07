#requires -version 2.0
## PoshCode module v 3.6
## UPDATED FOR CTP3 
## See comments for each function for changes ...
##############################################################################################################
## Provides cmdlets for working with scripts from the PoshCode Repository:
## Get-PoshCodeUpgrade - get the latest version of this script from the PoshCode server
## Get-PoshCode  - Search for and download code snippets
## New-PoshCode  - Upload new code snippets
## Remove-DownloadFlag  - Unblock files downloaded from the internet
## Set-DownloadFlag    - Mark files as downloaded (used by Get-PoshCode)
## Get-WebFile   - Download
##############################################################################################################
Set-StrictMode -Version Latest

$PoshCode = "http://PoshCode.org/" | 
      Add-Member -type NoteProperty -Name "UserName" -Value "Anonymous" -Passthru |
      Add-Member -type ScriptProperty -Name "ScriptLocation" -Value {
         $module = $null
         Get-Module PoshCode | Select -expand Path -EA "SilentlyContinue" | Tee -var module
         if(!$module) { # Try finding it by path, since it's not loaded as "PoshCode"
            Get-Module | ? {$_.Name -match "^$([RegEx]::Escape($PsScriptRoot))"} | Select -expand Path
         }
      } -Passthru |
      Add-Member -type ScriptProperty -Name "ModuleName" -Value {
         if( Get-Module PoshCode ) { "PoshCode" } else {
            Get-Module | ? {$_.Name -match "^$([RegEx]::Escape($PsScriptRoot))"} | Select -expand Name
         }
      } -Passthru |      
      Add-Member -type NoteProperty -Name "ScriptVersion" -Value 3.5 -Passthru |
      Add-Member -type NoteProperty -Name "ApiVersion" -Value 1 -Passthru

## Set-DownloadFlag
##############################################################################################################
## marks code as being "remote" (i.e.: downloaded from the internet)
## That is, we set the alternate data stream, like IE7 or Firefox3 would
##############################################################################################################
function Set-DownloadFlag {
[CmdletBinding()]
PARAM (
   [Parameter(Position=0, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $Path
,
   [Switch]$Passthru
)
   $FS = new-object NTFS.FileStreams($Path)
   $null = $fs.add('Zone.Identifier')
   $stream = $fs.Item('Zone.Identifier').open()

   $sw = [System.IO.streamwriter]$stream
   $Sw.writeline('[ZoneTransfer]')
   $sw.writeline('ZoneID=4')
   $sw.close()
   $stream.close()
   if($Passthru){ Get-ChildItem $Path }
}

## Remove-DownloadFlag
##############################################################################################################
## removes the alternate data stream that marks code as being "remote" (i.e.: downloaded from the internet)
##############################################################################################################
function Remove-DownloadFlag {
[CmdletBinding()]
PARAM (
   [Parameter(Position=0, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $Path
,
   [Switch]$Passthru
)
   $FS = new-object NTFS.FileStreams($Path)
   $null = $fs['Zone.Identifier'].delete()
   if($Passthru){ Get-ChildItem $Path }
}

## New-PoshCode (formerly Send-Paste)
##############################################################################################################
## Uploads code to the PowerShell Script Repository and returns the url for you.
##############################################################################################################
## Usage:
##    get-content myscript.ps1 | New-PoshCode "An example for you" "This is just to show how to do it"
##       would send the script with the specified title and description
##    ls *.ps1 | New-PoshCode -Keep Forever
##       would flood the pastebin site with all your scripts, using filename as the title
##       and a generic description, and mark them for storing indefinitely
##    get-history -count 5 | % { $_.CommandLine } | New-PoshCode
##       would paste the last 5 commands in your history!
##############################################################################################################
## History:
## v 3.1 - Fixed the $URL parameter so that it's settable again. *This* function should work on any pastebin site
## v 3.0 - Renamed to New-PoshCode.  
##         Removed the -Permanent switch, since this is now exclusive to the permanent repository
## v 2.1 - Changed some defaults
##       - Added "PermanentPosh" switch ( -P ) to switch the upload to the PowerShellCentral repository
## v 2.0 - works with "pastebin" (including posh.jaykul.com/p/ and PowerShellCentral.com/scripts/)
## v 1.0 - Worked with a special pastebin
##############################################################################################################
function New-PoshCode {
[CmdletBinding()]
PARAM(
   [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $Path
,
   [Parameter(Position=5, Mandatory=$true)][string]$Description
, 
   [Parameter(Position=10)][string]$Author = $($PoshCode.UserName)
, 
   [Parameter(Position=15)][PoshCodeLanguage]$Language="posh"
, 
   [Parameter(Position=20, Mandatory=$false)]
   [ValidateScript({ if($_ -match "^[dmf]") { return $true } else { throw "Please specify 'day', 'month', or 'forever'" } })]
   [string]$Keep="f"
,
   [Alias("BaseName,Name")]
   [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [string]$Title
,
   [Parameter(Mandatory=$false)][string]$url= $($PoshCode)
)
   
BEGIN {
   $null = [Reflection.Assembly]::LoadWithPartialName("System.Web")
   [string]$data = ""
   [string]$meta = ""
   
   if($language) {
      $meta = "format=" + [System.Web.HttpUtility]::UrlEncode($language)
      # $url = $url + "?" +$lang
   } else {
      $meta = "format=text"
   }

   # Note how simplified this is by 
   switch -regex ($Keep) {
      "^d" { $meta += "&expiry=d" }
      "^m" { $meta += "&expiry=m" }
      "^f" { $meta += "&expiry=f" }
   }
 
   if($Description) {
      $meta += "&descrip=" + [System.Web.HttpUtility]::UrlEncode($Description)
   } else {
      $meta += "&descrip="
   }   
   $meta += "&poster=" + [System.Web.HttpUtility]::UrlEncode($Author)
   
   function Send-PoshCode ($meta, $title, $data, $url= $($PoshCode)) {
      $meta += "&paste=Send&posttitle=" + [System.Web.HttpUtility]::UrlEncode($Title)
      $data = $meta + "&code2=" + [System.Web.HttpUtility]::UrlEncode($data)
     
      $request = [System.Net.WebRequest]::Create($url)
      $request.ContentType = "application/x-www-form-urlencoded"
      $request.ContentLength = $data.Length
      $request.Method = "POST"
 
      $post = new-object IO.StreamWriter $request.GetRequestStream()
      $post.Write($data,0,$data.Length)
      $post.Flush()
      $post.Close()
 
      # $reader = new-object IO.StreamReader $request.GetResponse().GetResponseStream() ##,[Text.Encoding]::UTF8
      # write-output $reader.ReadToEnd()
      # $reader.Close()
      write-output $request.GetResponse().ResponseUri.AbsoluteUri
      $request.Abort()
   }
}
PROCESS {
   $EAP = $ErrorActionPreference
   $ErrorActionPreference = "SilentlyContinue"
   if(Test-Path $Path -PathType Leaf) {
      $ErrorActionPreference = $EAP
      Write-Verbose $Path
      Write-Output $(Send-PoshCode $meta $Title $([string]::join("`n",(Get-Content $Path))) $url)
   } elseif(Test-Path $Path -PathType Container) {
      $ErrorActionPreference = $EAP
      Write-Error "Can't upload folders yet: $Path"
   } else { ## Todo, handle folders?
      $ErrorActionPreference = $EAP
      if(!$data -and !$Title){
         $Title = Read-Host "Give us a title for your post"
      }
      $data += "`n" + $Path
   }
}
END {
   if($data) { 
      Write-Output $(Send-PoshCode $meta $Title $data $url)
   }
}
}
 
## Get-PoshCode (download Repository script)
##############################################################################################################
## Downloads a specified script from a Pastbin.com based site, by Id
## ### OR ###
## Searches the powershellcentral.com/script site and returns lists of results
## All search terms are automatically surrounded with wildcards
## NOTE: powershellcentral.com currently uses MySql fulltext search syntax...
##############################################################################################################
## Usage:
##    Get-PoshCode Authenticode
##       will search the repository for scripts dealing with Authenticode, and list the results
##       Normally, you will take one of those IDs and do this:
##    Get-PoshCode 456
##       will download the script 456 and save it to file (based on it's name/contents)
##       This example would yield a file: Get_Set Signature (CTP2).psm1
##    Get-PoshCode 456 -passthru 
##       would output the contents of that script into the pipeline, so eg:
##       (Get-PoshCode 456 -passthru) -replace "AuthenticodeSignature","SillySig"
##    Get-PoshCode 456 $ProfileDir\Authenticode.psm1
##       would download the script to Authenticode.ps1 in the specified directory
##    Get-PoshCode SCOM | Get-PoshCode
##       would search the repository for all scripts about SCOM, and then download them!
##    Get-PoshCode SCOM | Get-PoshCode | Remove-DownloadFlag
##       would search the repository for all scripts about SCOM, and then download them and unblock them
##       see the comments on Set-DownloadFlag and Remove-DownloadFlag
##############################################################################################################
## History:
## v 3.4 - Add "-Language" parameter to force PowerShell only, fix upgrade to leave INVALID as .psm1
## v 3.2 - Add "-Upgrade" switch to cause the script to upgrade itself.
## v 3.1 - Add "Huddled.PoshCode.ScriptInfo" to TypeInfo, so it can be formatted by a ps1xml
##       - Add ConvertTo-Module function to try to rename .ps1 scripts to .psm1 
##       - Fixed exceptions thrown by searches which return no results
##       - Removed the auto-wildcards!!!!
##          NOTE: to get the same results as before you must now put * on the front and end of searches
##          This is so that searches on the website work the same as searches here...
##          My intention is to improve the website's search instead of leaving this here.
##          NOTE: the website currently will not search for words less than 4 characters long
## v 3.0 - Working against the new RSS-based API
##         - And using ParameterSets, which work in CTP2
## v 2.0 - Combined with Find-Poshcode into a single script
## v 1.0 - Working against our special pastebin
##############################################################################################################
function Get-PoshCode {
[CmdletBinding(DefaultParameterSetName="Download")]
   PARAM(
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Search")]
      [string]$Query
,
      [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Download" )]
      [int]$Id
,
      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Upgrade")]
      [switch]$Upgrade
,
      [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
      [Alias("FullName")]
      [string]$SaveAs
,
      [Parameter(Position=2, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
      [ValidateSet('text','asp','bash','cpp','csharp','posh','vbnet','xml','all')]
      [string]$Language="posh"
,
      [switch]$InBrowser
,
      [switch]$Passthru
,
      [Parameter(Mandatory=$false)][string]$url= $($PoshCode)
   )
PROCESS {
   Write-Debug "ParameterSet Name: $($PSCmdlet.ParameterSetName)"
   if($Language -eq 'all') { $Language = "" }
   switch($PSCmdlet.ParameterSetName) {
      "Search" {
         $results = @(([xml](Get-WebFile "$($url)api$($PoshCode.ApiVersion)/$($query)&lang=$($Language)" -passthru)).rss.channel.GetElementsByTagName("item"))
         if($results.Count -eq 0 ) {
            Write-Host "Zero Results for '$query'" -Fore Red -Back Black
         } 
         else {
            $results | Select @{ n="Id";e={$($_.link -replace $url,'') -as [int]}},
                @{n="Title";e={$_.title}},
                @{n="Author";e={$_.creator}},
                @{n="Date";e={$_.pubDate }},
                @{n="Link";e={$_.guid.get_InnerText() }},
                @{n="Description";e={"$($_.description.get_InnerText())`n" }} |
            ForEach { $_.PSObject.TypeNames.Insert( 0, "Huddled.PoshCode.ScriptInfo" ); $_ }
         }
      }
      "Download" {
         if(!$InBrowser) {
            if($Passthru) {
               Get-WebFile "$($url)?dl=$id" -Passthru
            } 
            elseif($SaveAs) {
               Get-WebFile "$($url)?dl=$id" -fileName $SaveAs | ConvertTo-Module | Set-DownloadFlag -Passthru
            } 
            else {
               Get-WebFile "$($url)?dl=$id" | ConvertTo-Module | Set-DownloadFlag -Passthru
            }
         } 
         else {
            [Diagnostics.Process]::Start( "$($url)$id" )
         }
      }
      "Upgrade" { 
         Get-PoshCodeUpgrade
      }
   }
}
}

## Get-PoshCodeUpgrade
##############################################################################################################
## Downloads a new PoshCode script version, and archives old versions..
##############################################################################################################
## History:
## v3.3 - Removes old versions, and checks the signature.
## v3.2 - First script version with Upgrade function
##############################################################################################################
function Get-PoshCodeUpgrade {
   $VersionFile = [IO.Path]::ChangeExtension( $PoshCode.ScriptLocation,
                  ("{0}{1}" -f  $PoshCode.ScriptVersion, [IO.Path]::GetExtension($PoshCode.ScriptLocation)))
   # Copy it to make sure we don't loose it
   Copy-Item $PoshCode.ScriptLocation $VersionFile
   # Remove old ones ...
   Remove-Item (  [IO.Path]::ChangeExtension( $PoshCode.ScriptLocation, 
                  ".*$([IO.Path]::GetExtension( $($PoshCode.ScriptLocation) ))") 
               ) -exclude ([IO.Path]::GetFileName($VersionFile)) -Confirm
   # Finally, get the new one
   $NewFile = Get-WebFile "$($PoshCode)PoshCode.psm1" -fileName (
                          [IO.Path]::ChangeExtension( $PoshCode.ScriptLocation, ".INVALID.ps1"))
   if( Test-Signature -File $NewFile )
   {
      Move-Item $NewFile $PoshCode.ScriptLocation -Force -passthru | Remove-DownloadFlag -Passthru
      Add-Module $($PoshCode.ModuleName) -Force
   } 
   else { 
      Write-Error "Signature is Not Valid on new version."
      Move-Item $NewFile ([IO.Path]::ChangeExtension( $PoshCode.ScriptLocation, ".INVALID.psm1"))
      Get-Item ([IO.Path]::ChangeExtension( $PoshCode.ScriptLocation, ".INVALID.psm1"))
   }
}

## Test-Signature - Returns true if the signature is valid OR is signed by "F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5"
function Test-Signature {
[CmdletBinding(DefaultParameterSetName="File")]
PARAM (
   [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Signature")]
   #  We can't actually require the type, or we won't be able to check the fake ones from Joel's Authenticode module
   #  [System.Management.Automation.Signature]
   $Signature
,  [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="File")]
   [System.IO.FileInfo]
   $File
)
PROCESS {
   if($File -and (Test-Path $File -PathType Leaf)) {
      $Signature = Get-AuthenticodeSignature $File
   }
   if(!$Signature) { return $false } else {
      $result = $false;
      try {
         $result = ((($Signature.Status -eq "UnknownError") -and $Signature.SignerCertificate -and
                     ($Signature.SignerCertificate.Thumbprint -eq "F05F583BB5EA4C90E3B9BF1BDD0B657701245BD5") 
                    ) -or $Signature.Status -eq "Valid" )
      } catch { } finally { return $result }
   }
}
}

filter ConvertTo-Module {
   $oldFile  = $_
   if( ([IO.Path]::GetExtension($oldFile) -eq ".ps1") -and 
         [Regex]::Match( [IO.File]::ReadAllText($oldFile), 
              "^[^#]*Export-ModuleMember.*", "MultiLine").Success )
   { 
      $fileName = [IO.Path]::ChangeExtension($oldFile, ".psm1")
      Move-Item $oldFile $fileName -Force
      Get-Item $fileName
   } else { $oldFile } 
}

## Get-WebFile (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
## v3.8 - Add UserAgent calculation and parameter
## v3.7 - Add file-name guessing and cleanup
## v3.6 - Add -Passthru switch to output TEXT files 
## v3.5 - Add -Quiet switch to turn off the progress reports ...
## v3.4 - Add progress report for files which don't report size
## v3.3 - Add progress report for files which report their size
## v3.2 - Use the pure Stream object because StreamWriter is based on TextWriter:
##        it was messing up binary files, and making mistakes with extended characters in text
## v3.1 - Unwrap the filename when it has quotes around it
## v3   - rewritten completely using HttpWebRequest + HttpWebResponse to figure out the file name, if possible
## v2   - adds a ton of parsing to make the output pretty
##        added measuring the scripts involved in the command, (uses Tokenizer)
##############################################################################################################
function Get-WebFile {
   param( 
      $url = (Read-Host "The URL to download"),
      $fileName = $null,
      [switch]$Passthru,
      [switch]$quiet,
      [string]$UserAgent = "PoshCode/$($PoshCode.ScriptVersion)"      
   )

   Write-Verbose "Downloading '$url'"

   $req = [System.Net.HttpWebRequest]::Create($url);
   $req.UserAgent = $(
         "{0} (PowerShell {1}; .NET CLR {2}; {3}; http://PoshCode.org)" -f $UserAgent, 
         $(if($Host.Version){$Host.Version}else{"1.0"}),
         [Environment]::Version,
         [Environment]::OSVersion.ToString().Replace("Microsoft Windows ", "Win")
      ) 
   $res = $req.GetResponse();
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Convert-Path (Get-Location -PSProvider "FileSystem")) $fileName
   }
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
      
      $ofs = ""
      $fileName = [Regex]::Replace($fileName, "[$([Regex]::Escape(""$([System.IO.Path]::GetInvalidPathChars())$([IO.Path]::AltDirectorySeparatorChar)$([IO.Path]::DirectorySeparatorChar)""))]", "_")
      $ofs = " "
      
      if(!$fileName) {
         $fileName = $res.ResponseUri.Segments[-1]
         $fileName = $fileName.trim("\/")
         if(!$fileName) { 
            $fileName = Read-Host "Please provide a file name"
         }
         $fileName = $fileName.trim("\/")
         if(!([IO.FileInfo]$fileName).Extension) {
            $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
         }
      }
      $fileName = Join-Path (Convert-Path (Get-Location -PSProvider "FileSystem")) $fileName
   }
   if($Passthru) {
      $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
      [string]$output = ""
   }
 
   if($res.StatusCode -eq 200) {
      [int]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         $writer = new-object System.IO.FileStream $fileName, "Create"
      }
      [byte[]]$buffer = new-object byte[] 4096
      [int]$total = [int]$count = 0
      do
      {
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         } 
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $url" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100)
            } else {
               Write-Progress "Downloading $url" "Saving $total bytes..." -id 0
            }
         }
      } while ($count -gt 0)
      
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   $res.Close(); 
   if($fileName) {
      Set-DownloadFlag $fileName -PassThru
   }
}

Export-ModuleMember Get-PoshCode, New-PoshCode, Remove-DownloadFlag, Set-DownloadFlag, Get-WebFile, Get-PoshCodeUpgrade

#Add-Type -Path "$PsScriptRoot\NTFS.cs"
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;


///<summary>
///Encapsulates access to alternative data streams of an NTFS file.
///Adapted from a C++ sample by Dino Esposito,
///http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnfiles/html/ntfs5.asp
///</summary>
namespace NTFS {
   /// <summary>
   /// Wraps the API functions, structures and constants.
   /// </summary>
   internal class Kernel32 
   {
      public const char STREAM_SEP = ':';
      public const int INVALID_HANDLE_VALUE = -1;
      public const int MAX_PATH = 256;
      
      [Flags()] public enum FileFlags : uint
      {
         WriteThrough = 0x80000000,
         Overlapped = 0x40000000,
         NoBuffering = 0x20000000,
         RandomAccess = 0x10000000,
         SequentialScan = 0x8000000,
         DeleteOnClose = 0x4000000,
         BackupSemantics = 0x2000000,
         PosixSemantics = 0x1000000,
         OpenReparsePoint = 0x200000,
         OpenNoRecall = 0x100000
      }

      [Flags()] public enum FileAccessAPI : uint
      {
         GENERIC_READ = 0x80000000,
         GENERIC_WRITE = 0x40000000
      }
      /// <summary>
      /// Provides a mapping between a System.IO.FileAccess value and a FileAccessAPI value.
      /// </summary>
      /// <param name="Access">The <see cref="System.IO.FileAccess"/> value to map.</param>
      /// <returns>The <see cref="FileAccessAPI"/> value.</returns>
      public static FileAccessAPI Access2API(FileAccess Access) 
      {
         FileAccessAPI lRet = 0;
         if ((Access & FileAccess.Read)==FileAccess.Read) lRet |= FileAccessAPI.GENERIC_READ;
         if ((Access & FileAccess.Write)==FileAccess.Write) lRet |= FileAccessAPI.GENERIC_WRITE;
         return lRet;
      }

      [StructLayout(LayoutKind.Sequential)] public struct LARGE_INTEGER 
      {
         public int Low;
         public int High;

         public long ToInt64() 
         {
            return (long)High * 4294967296 + (long)Low;
         }
      }

      [StructLayout(LayoutKind.Sequential)] public struct WIN32_STREAM_ID 
      {
         public int dwStreamID;
         public int dwStreamAttributes;
         public LARGE_INTEGER Size;
         public int dwStreamNameSize;
      }
      
      [DllImport("kernel32")] public static extern SafeFileHandle CreateFile(string Name, FileAccessAPI Access, FileShare Share, int Security, FileMode Creation, FileFlags Flags, int Template);
      [DllImport("kernel32")] public static extern bool DeleteFile(string Name);
      [DllImport("kernel32")] public static extern bool CloseHandle(SafeFileHandle hObject);

      [DllImport("kernel32")] public static extern bool BackupRead(SafeFileHandle hFile, IntPtr pBuffer, int lBytes, ref int lRead, bool bAbort, bool bSecurity, ref int Context);
      [DllImport("kernel32")] public static extern bool BackupRead(SafeFileHandle hFile, ref WIN32_STREAM_ID pBuffer, int lBytes, ref int lRead, bool bAbort, bool bSecurity, ref int Context);
      [DllImport("kernel32")] public static extern bool BackupSeek(SafeFileHandle hFile, int dwLowBytesToSeek, int dwHighBytesToSeek, ref int dwLow, ref int dwHigh, ref int Context);
   }

   /// <summary>
   /// Encapsulates a single alternative data stream for a file.
   /// </summary>
   public class StreamInfo 
   {
      private FileStreams _parent;
      private string _name;
      private long _size;

      internal StreamInfo(FileStreams Parent, string Name, long Size) 
      {
         _parent = Parent;
         _name = Name;
         _size = Size;
      }

      /// <summary>
      /// The name of the stream.
      /// </summary>
      public string Name 
      {
         get { return _name; }
      }
      /// <summary>
      /// The size (in bytes) of the stream.
      /// </summary>
      public long Size 
      {
         get { return _size; }
      }
      
      public override string ToString() 
      {
         return String.Format("{1}{0}{2}{0}$DATA", Kernel32.STREAM_SEP, _parent.FileName, _name);
      }
      public override bool Equals(Object o) 
      {
         if (o is StreamInfo) 
         {
            StreamInfo f = (StreamInfo)o;
            return (f._name.Equals(_name) && f._parent.Equals(_parent));
         }
         else if (o is string) 
         {
            return ((string)o).Equals(ToString());
         }
         else
            return base.Equals(o);
      }
      public override int GetHashCode() 
      {
         return ToString().GetHashCode();
      }

#region Open
      /// <summary>
      /// Opens or creates the stream in read-write mode, with no sharing.
      /// </summary>
      /// <returns>A <see cref="System.IO.FileStream"/> wrapper for the stream.</returns>
      public FileStream Open() 
      {
         return Open(FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
      }
      /// <summary>
      /// Opens or creates the stream in read-write mode with no sharing.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> action for the stream.</param>
      /// <returns>A <see cref="System.IO.FileStream"/> wrapper for the stream.</returns>
      public FileStream Open(FileMode Mode) 
      {
         return Open(Mode, FileAccess.ReadWrite, FileShare.None);
      }
      /// <summary>
      /// Opens or creates the stream with no sharing.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> action for the stream.</param>
      /// <param name="Access">The <see cref="System.IO.FileAccess"/> level for the stream.</param>
      /// <returns>A <see cref="System.IO.FileStream"/> wrapper for the stream.</returns>
      public FileStream Open(FileMode Mode, FileAccess Access) 
      {
         return Open(Mode, Access, FileShare.None);
      }
      /// <summary>
      /// Opens or creates the stream.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> action for the stream.</param>
      /// <param name="Access">The <see cref="System.IO.FileAccess"/> level for the stream.</param>
      /// <param name="Share">The <see cref="System.IO.FileShare"/> level for the stream.</param>
      /// <returns>A <see cref="System.IO.FileStream"/> wrapper for the stream.</returns>
      public FileStream Open(FileMode Mode, FileAccess Access, FileShare Share) 
      {
         try 
         {
            SafeFileHandle hFile = Kernel32.CreateFile(ToString(), Kernel32.Access2API(Access), Share, 0, Mode, 0, 0);
            return new FileStream(hFile, Access);
         }
         catch 
         {
            return null;
         }
      }
#endregion

#region Delete
      /// <summary>
      /// Deletes the stream from the file.
      /// </summary>
      /// <returns>A <see cref="System.Boolean"/> value: true if the stream was deleted, false if there was an error.</returns>
      public bool Delete() 
      {
         return Kernel32.DeleteFile(ToString());
      }
#endregion
   }


   /// <summary>
   /// Encapsulates the collection of alternative data streams for a file.
   /// A collection of <see cref="StreamInfo"/> objects.
   /// </summary>
   public class FileStreams : CollectionBase 
   {
      private FileInfo _file;

#region Constructors
      public FileStreams(string File) 
      {
         _file = new FileInfo(File);
         initStreams();
      }
      public FileStreams(FileInfo file) 
      {
         _file = file;
         initStreams();
      }

      /// <summary>
      /// Reads the streams from the file.
      /// </summary>
      private void initStreams() 
      {
         //Open the file with backup semantics
         SafeFileHandle hFile = Kernel32.CreateFile(_file.FullName, Kernel32.FileAccessAPI.GENERIC_READ, FileShare.Read, 0, FileMode.Open, Kernel32.FileFlags.BackupSemantics, 0);
         if (hFile.IsInvalid) return;

         try 
         {
            Kernel32.WIN32_STREAM_ID sid = new Kernel32.WIN32_STREAM_ID();
            int dwStreamHeaderSize = Marshal.SizeOf(sid);
            int Context = 0;
            bool Continue = true;
            while (Continue) 
            {
               //Read the next stream header
               int lRead = 0;
               Continue = Kernel32.BackupRead(hFile, ref sid, dwStreamHeaderSize, ref lRead, false, false, ref Context);
               if (Continue && lRead == dwStreamHeaderSize) 
               {
                  if (sid.dwStreamNameSize>0) 
                  {
                     //Read the stream name
                     lRead = 0;
                     IntPtr pName = Marshal.AllocHGlobal(sid.dwStreamNameSize);
                     try 
                     {
                        Continue = Kernel32.BackupRead(hFile, pName, sid.dwStreamNameSize, ref lRead, false, false, ref Context);
                        char[] bName = new char[sid.dwStreamNameSize];
                        Marshal.Copy(pName,bName,0,sid.dwStreamNameSize);

                        //Name is of the format ":NAME:$DATA\0"
                        string sName = new string(bName);
                        int i = sName.IndexOf(Kernel32.STREAM_SEP, 1);
                        if (i>-1) sName = sName.Substring(1, i-1);
                        else 
                        {
                           //This should never happen. 
                           //Truncate the name at the first null char.
                           i = sName.IndexOf('\0');
                           if (i>-1) sName = sName.Substring(1, i-1);
                        }

                        //Add the stream to the collection
                        base.List.Add(new StreamInfo(this,sName,sid.Size.ToInt64()));
                     }
                     finally 
                     {
                        Marshal.FreeHGlobal(pName);
                     }
                  }

                  //Skip the stream contents
                  int l = 0; int h = 0;
                  Continue = Kernel32.BackupSeek(hFile, sid.Size.Low, sid.Size.High, ref l, ref h, ref Context);
               }
               else break;
            }
         }
         finally 
         {
            Kernel32.CloseHandle(hFile);
         }
      }
#endregion

#region File
      /// <summary>
      /// Returns the <see cref="System.IO.FileInfo"/> object for the wrapped file. 
      /// </summary>
      public FileInfo FileInfo 
      {
         get { return _file; }
      }
      /// <summary>
      /// Returns the full path to the wrapped file.
      /// </summary>
      public string FileName 
      {
         get { return _file.FullName; }
      }

      /// <summary>
      /// Returns the size of the main data stream, in bytes.
      /// </summary>
      public long FileSize {
         get {return _file.Length;}
      }

      /// <summary>
      /// Returns the size of all streams for the file, in bytes.
      /// </summary>
      public long Size 
      {
         get 
         {
            long size = this.FileSize;
            foreach (StreamInfo s in this) size += s.Size;
            return size;
         }
      }
#endregion

#region Open
      /// <summary>
      /// Opens or creates the default file stream.
      /// </summary>
      /// <returns><see cref="System.IO.FileStream"/></returns>
      public FileStream Open() 
      {
         return new FileStream(_file.FullName, FileMode.OpenOrCreate);
      }

      /// <summary>
      /// Opens or creates the default file stream.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> for the stream.</param>
      /// <returns><see cref="System.IO.FileStream"/></returns>
      public FileStream Open(FileMode Mode) 
      {
         return new FileStream(_file.FullName, Mode);
      }

      /// <summary>
      /// Opens or creates the default file stream.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> for the stream.</param>
      /// <param name="Access">The <see cref="System.IO.FileAccess"/> for the stream.</param>
      /// <returns><see cref="System.IO.FileStream"/></returns>
      public FileStream Open(FileMode Mode, FileAccess Access) 
      {
         return new FileStream(_file.FullName, Mode, Access);
      }

      /// <summary>
      /// Opens or creates the default file stream.
      /// </summary>
      /// <param name="Mode">The <see cref="System.IO.FileMode"/> for the stream.</param>
      /// <param name="Access">The <see cref="System.IO.FileAccess"/> for the stream.</param>
      /// <param name="Share">The <see cref="System.IO.FileShare"/> for the stream.</param>
      /// <returns><see cref="System.IO.FileStream"/></returns>
      public FileStream Open(FileMode Mode, FileAccess Access, FileShare Share) 
      {
         return new FileStream(_file.FullName, Mode, Access, Share);
      }
#endregion

#region Delete
      /// <summary>
      /// Deletes the file, and all alternative streams.
      /// </summary>
      public void Delete() 
      {
         for (int i=base.List.Count;i>0;i--) 
         {
            base.List.RemoveAt(i);
         }
         _file.Delete();
      }
#endregion

#region Collection operations
      /// <summary>
      /// Add an alternative data stream to this file.
      /// </summary>
      /// <param name="Name">The name for the stream.</param>
      /// <returns>The index of the new item.</returns>
      public int Add(string Name) 
      {
         StreamInfo FSI = new StreamInfo(this, Name, 0);
         int i = base.List.IndexOf(FSI);
         if (i==-1) i = base.List.Add(FSI);
         return i;
      }
      /// <summary>
      /// Removes the alternative data stream with the specified name.
      /// </summary>
      /// <param name="Name">The name of the string to remove.</param>
      public void Remove(string Name) 
      {
         StreamInfo FSI = new StreamInfo(this, Name, 0);
         int i = base.List.IndexOf(FSI);
         if (i>-1) base.List.RemoveAt(i);
      }

      /// <summary>
      /// Returns the index of the specified <see cref="StreamInfo"/> object in the collection.
      /// </summary>
      /// <param name="FSI">The object to find.</param>
      /// <returns>The index of the object, or -1.</returns>
      public int IndexOf(StreamInfo FSI) 
      {
         return base.List.IndexOf(FSI);
      }
      /// <summary>
      /// Returns the index of the <see cref="StreamInfo"/> object with the specified name in the collection.
      /// </summary>
      /// <param name="Name">The name of the stream to find.</param>
      /// <returns>The index of the stream, or -1.</returns>
      public int IndexOf(string Name) 
      {
         return base.List.IndexOf(new StreamInfo(this, Name, 0));
      }

      public StreamInfo this[int Index] 
      {
         get { return (StreamInfo)base.List[Index]; }
      }
      public StreamInfo this[string Name] 
      {
         get 
         { 
            int i = IndexOf(Name);
            if (i==-1) return null;
            else return (StreamInfo)base.List[i];
         }
      }
#endregion

#region Overrides
      /// <summary>
      /// Throws an exception if you try to add anything other than a StreamInfo object to the collection.
      /// </summary>
      protected override void OnInsert(int index, object value) 
      {
         if (!(value is StreamInfo)) throw new InvalidCastException();
      }
      /// <summary>
      /// Throws an exception if you try to add anything other than a StreamInfo object to the collection.
      /// </summary>
      protected override void OnSet(int index, object oldValue, object newValue) 
      {
         if (!(newValue is StreamInfo)) throw new InvalidCastException();
      }

      /// <summary>
      /// Deletes the stream from the file when you remove it from the list.
      /// </summary>
      protected override void OnRemoveComplete(int index, object value) 
      {
         try 
         {
            StreamInfo FSI = (StreamInfo)value;
            if (FSI != null) FSI.Delete();
         }
         catch {}
      }

      public new StreamEnumerator GetEnumerator() 
      {
         return new StreamEnumerator(this);
      }
#endregion

#region StreamEnumerator
      public class StreamEnumerator : object, IEnumerator 
      {
         private IEnumerator baseEnumerator;
            
         public StreamEnumerator(FileStreams mappings) 
         {
            this.baseEnumerator = ((IEnumerable)(mappings)).GetEnumerator();
         }
            
         public StreamInfo Current 
         {
            get 
            {
               return ((StreamInfo)(baseEnumerator.Current));
            }
         }
            
         object IEnumerator.Current 
         {
            get 
            {
               return baseEnumerator.Current;
            }
         }
            
         public bool MoveNext() 
         {
            return baseEnumerator.MoveNext();
         }
            
         bool IEnumerator.MoveNext() 
         {
            return baseEnumerator.MoveNext();
         }
            
         public void Reset() 
         {
            baseEnumerator.Reset();
         }
            
         void IEnumerator.Reset() 
         {
            baseEnumerator.Reset();
         }
      }
#endregion
   }
}
'@

Add-Type -TypeDefinition @'
public enum PoshCodeLanguage {
   asp,                       
   bash,
   csharp,
   posh,
   vbnet,
   xml,
   text
}
'@


# SIG # Begin signature block
# MIIIPgYJKoZIhvcNAQcCoIIILzCCCCsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3i+MeuLT7EgZ9YB0FHRT5Ecq
# VKigggVbMIIFVzCCBD+gAwIBAgIRAO2rPg5HUjL4ofGGpnMP2jwwDQYJKoZIhvcN
# AQEFBQAwgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2Fs
# dCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8G
# A1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNF
# UkZpcnN0LU9iamVjdDAeFw0wODEwMDYwMDAwMDBaFw0wOTEwMDYyMzU5NTlaMIHE
# MQswCQYDVQQGEwJVUzEOMAwGA1UEEQwFMTQ2MjMxETAPBgNVBAgMCE5ldyBZb3Jr
# MRIwEAYDVQQHDAlSb2NoZXN0ZXIxFDASBgNVBAkMC01TIDA4MDEtMTdBMRowGAYD
# VQQJDBExMzUwIEplZmZlcnNvbiBSZDEaMBgGA1UECgwRWGVyb3ggQ29ycG9yYXRp
# b24xFDASBgNVBAsMC1NFRURVIFRvb2xzMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK50RXT2KUvECfWZ
# weqeXzTCykPPRh9nC3Hzur/mmvkQHA8iinnSKX4j19C1/MV0rAEeCU1bF7Sgxvov
# ORreM1Ye/wEqJLAUP/IGZI/qsmmwasGFGbnuevpA3WieNCr5cFGl8Y5Mx6ejaDFi
# O0GT9EM6gOGZaEEMRbHZc4qXT7CrWScs4Yur5bBZsowaMk5JkvZgihhnN93QolEW
# ObmtQZlbBDqLuoL9fUnIexlqqIrC/4h0K8VM26HvqhgGlQF2wf4t9xCHFJiX2F7D
# B10lef5aXzyPVrvxxrRWyBtCQuL7xdXneRanJaYG3B3kclc+4/6dq9a+s/huXjmE
# omumgGcCAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBT5ITlG5CdiD+nI0uTqnXNGnd44QjAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAWGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAZxnV+BbJBohpy+wKs6U8hRiPUhDYaijzTyrZontf5
# PEyBbhAkJFIWauIaq9eSQEJeErXO/zuO6+wY/azBzOTleMM9qdGWHFtfAw5WiIuC
# 90TzDBSuP7LImZV5Pb6nxRbesDF2U7EM5sBzYSWAMfpBmYRz97EHPW5QNzpBLFJn
# Dhb/M27rDYh7FVjy1+C5E3glIa0A0q+lcxEtFuUij4JId+oMcfpSgYJZvR1Kvkjd
# GDAtWCzvALaNFd65kChbrOqcClOCacQRnP9N4DJl/RVNKZtcUcVAyTpvOlJBA5vG
# OVcsJT4TnSMjPX6d5pXMwcE1oWCUWvK99W+N81DvBBuZMYICTTCCAkkCAQEwgasw
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIRAO2rPg5HUjL4ofGGpnMP2jwwCQYFKw4DAhoFAKB4MBgGCisGAQQB
# gjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJCfFRIe
# gnXhrIKjkzVOt1jE84TEMA0GCSqGSIb3DQEBAQUABIIBAG3iODNS+O0q4aYM07kf
# IWWW2A0c/l97T9dB2LMCD487shUAw0mltu/ZxdUSO3rPILGepaB3Iboi6TyZN76n
# 2PfxrMZ3nBKs2OC4/8ULoyUk/n8An1u0e2dfHoS8VprOgwZel0ecn8RFnp4P8fvJ
# 3UFs83JiGlZKVD9Dx3isQpZ2b8QpWd8H1//GE0+4p/Gb2t8yfTaEAy8MxI6uQjnF
# DK/b/me6UUwtffxZoUTvDjFWyV3aOHRKmmGQk7WCOipPnDq178BlU1JFq9FSPS6W
# PCgEZK/QKlN1iCkPGrDlVCiImx/2UZwq/RBjMF0CpLyKAvUi1llwICym8Mz5uKZc
# h38=
# SIG # End signature block
