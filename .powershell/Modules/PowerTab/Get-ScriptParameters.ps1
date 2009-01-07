#  Get-ScriptParameters
#  Retrieves the parameters for a script
# 
# /\/\o\/\/ 2008
# http://ThePowerShellGuy.com
#

Function global:Get-ScriptParameters ($path){
    if (!$path) {return}
    $sf = (gc $path) | out-String 
    $lf = $sf.Split("`n")
    $e = $lf.GetEnumerator()
    $morelines = $e.movenext()
    
    $Continue = $e.Current -match "(^\s*param\s*\(|^\s*#|)(.*)"
    if ($e.Current -match "^\s+$") {$Continue = $true}
    while ($continue -and $Morelines) { 
        $params = $matches[2] |? {$_}|% {$_.Split(',')}
        if ($Matches[1] -match 'param') {
            $level = 1
            while ($continue -and $morelines) {        
                
                $params | foreach {
                    [string]::join('',($_.getEnumerator() |% {
                        if ($_ -eq ')'){$level--}
                        elseif($_ -eq '('){$level++}
                        if ($level -eq 0) {$continue = $false}
                        if ($continue) {$_}
                    })).split('$')[1] |? {$_}|% {$_.split('=')[0]} |% {$_.replace(')','').trim()}
                    if (!$continue){break}
                }
                if ( $Continue ) {
                    $morelines = $e.movenext()
                    $params = $e.Current.Split(',')
                }
            }
        } else {
            $morelines = $e.MoveNext()
            $Continue = $e.Current -match "(^\s*param\s*\(|^\s*#)(.*)"
            if ($e.Current -match "^\s+$") {$Continue = $true}
        }
    }
}



#-------------------------------------------------------------------
# Digital Signature :
# Signed for the Powershell Guy by Getronics PinkRoccade.
#-------------------------------------------------------------------
# SIG # Begin signature block
# MIIVgQYJKoZIhvcNAQcCoIIVcjCCFW4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCWTvVCkyhEbHihcIJ+XUZVfX
# EOqgghEkMIIDejCCAmKgAwIBAgIQOCXX+vhhr570kOcmtdZa1TANBgkqhkiG9w0B
# AQUFADBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzAp
# BgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EwHhcNMDcw
# NjE1MDAwMDAwWhcNMTIwNjE0MjM1OTU5WjBcMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xNDAyBgNVBAMTK1ZlcmlTaWduIFRpbWUgU3RhbXBp
# bmcgU2VydmljZXMgU2lnbmVyIC0gRzIwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
# AoGBAMS18lIVvIiGYCkWSlsvS5Frh5HzNVRYNerRNl5iTVJRNHHCe2YdicjdKsRq
# CvY32Zh0kfaSrrC1dpbxqUpjRUcuawuSTksrjO5YSovUB+QaLPiCqljZzULzLcB1
# 3o2rx44dmmxMCJUe3tvvZ+FywknCnmA84eK+FqNjeGkUe60tAgMBAAGjgcQwgcEw
# NAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2ln
# bi5jb20wDAYDVR0TAQH/BAIwADAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# LnZlcmlzaWduLmNvbS90c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIGwDAeBgNVHREEFzAVpBMwETEPMA0GA1UEAxMGVFNBMS0y
# MA0GCSqGSIb3DQEBBQUAA4IBAQBQxUvIJIDf5A0kwt4asaECoaaCLQyDFYE3CoIO
# LLBaF2G12AX+iNvxkZGzVhpApuuSvjg5sHU2dDqYT+Q3upmJypVCHbC5x6CNV+D6
# 1WQEQjVOAdEzohfITaonx/LhhkwCOE2DeMb8U+Dr4AaH3aSWnl4MmOKlvr+ChcNg
# 4d+tKNjHpUtk2scbW72sOQjVOCKhM4sviprrvAchP0RBCQe1ZRwkvEjTRIDroc/J
# ArQUz1THFqOAXPl5Pl1yfYgXnixDospTzn099io6uE+UAKVtCoNd+V5T9BizVw9w
# w/v1rZWgDhfexBaAYMkPK26GBPHr9Hgn0QXF7jRbXrlJMvIzMIIDxDCCAy2gAwIB
# AgIQR78Zld+NUkZD99ttSA0xpDANBgkqhkiG9w0BAQUFADCBizELMAkGA1UEBhMC
# WkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIGA1UEBxMLRHVyYmFudmlsbGUx
# DzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhhd3RlIENlcnRpZmljYXRpb24x
# HzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcgQ0EwHhcNMDMxMjA0MDAwMDAw
# WhcNMTMxMjAzMjM1OTU5WjBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNp
# Z24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpyrKkzM0grwp9
# iayHdfC0TvHfwQ+/Z2G9o2Qc2rv5yjOrhDCJWH6M22vdNp4Pv9HsePJ3pn5vPL+T
# rw26aPRslMq9Ui2rSD31ttVdXxsCn/ovax6k96OaphrIAuF/TFLjDmDsQBx+uQ3e
# P8e034e9X3pqMS4DmYETqEcgzjFzDVctzXg0M5USmRK53mgvqubjwoqMKsOLIYdm
# vYNYV291vzyqJoddyhAVPJ+E6lTBCm7E/sVK3bkHEZcifNs+J9EeeOyfMcnx5iIZ
# 28SzR0OaGl+gHpDkXvXufPF9q2IBj/VNC97QIlaolc2uiHau7roN8+RN2aD7aKCu
# FDuzh8G7AgMBAAGjgdswgdgwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBBBgNV
# HR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLnZlcmlzaWduLmNvbS9UaGF3dGVUaW1l
# c3RhbXBpbmdDQS5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgEGMCQGA1UdEQQdMBukGTAXMRUwEwYDVQQDEwxUU0EyMDQ4LTEtNTMwDQYJKoZI
# hvcNAQEFBQADgYEASmv56ljCRBwxiXmZK5a/gqwB1hxMzbCKWG7fCCmjXsjKkxPn
# BFIN70cnLwA4sOTJk06a1CJiFfc/NyFPcDGA8Ys4h7Po6JcA/s9Vlk4k0qknTnqu
# t2FB8yrO58nZXt27K4U+tZ212eFX/760xX71zwye8Jf+K9M7UhsbOCf3P0owggS/
# MIIEKKADAgECAhBBkaFaOXjfz0llZjgdTHXCMA0GCSqGSIb3DQEBBQUAMF8xCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjE3MDUGA1UECxMuQ2xh
# c3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0w
# NDA3MTYwMDAwMDBaFw0xNDA3MTUyMzU5NTlaMIG0MQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5l
# dHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJp
# c2lnbi5jb20vcnBhIChjKTA0MS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAzIENv
# ZGUgU2lnbmluZyAyMDA0IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEAvrzuvH7vg+vgN0/7AxA4vgjSjH2d+pJ/GQzCa+5CUoze0xxIEyXqwWN6+VFl
# 7tOqO/XwlJwr+/Jm1CTa9/Wfbhk5NrzQo3YIHiInJGw4kSfihEmuG4qh/SWCLBAw
# 6HGrKOh3SlHx7M348FTUb8DjbQqP2dhkjWOyLU4n9oUO/m3jKZnihUd8LYZ/6FeP
# rWfCMzKREyD8qSMUmm3ChEt2aATVcSxdIfqIDSb9Hy2RK+cBVU3ybTUogt/Za1y2
# 1tmqgf1fzYO6Y53QIvypO0Jpso46tby0ng9exOosgoso/VMIlt21ASDR+aUY58Du
# UXA34bYFSFJIbzjqw+hse0SEuwIDAQABo4IBoDCCAZwwEgYDVR0TAQH/BAgwBgEB
# /wIBADBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcDMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwMQYDVR0fBCowKDAmoCSgIoYgaHR0
# cDovL2NybC52ZXJpc2lnbi5jb20vcGNhMy5jcmwwHQYDVR0lBBYwFAYIKwYBBQUH
# AwIGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIBBjARBglghkgBhvhCAQEEBAMCAAEw
# KQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEUNsYXNzM0NBMjA0OC0xLTQzMB0GA1Ud
# DgQWBBQI9VHo+/49PWQ2fGjPW3io37nFNzCBgAYDVR0jBHkwd6FjpGEwXzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFz
# cyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5ghBwuuQd
# ENkpNLY4ynsDzLq/MA0GCSqGSIb3DQEBBQUAA4GBAK46F7hKe1X6ZFXsQKTtSUGQ
# mZyJvK8uHcp4I/kcGQ9/62i8MtmION7cP9OJtD+xgpbxpFq67S4m0958AW4ACgCk
# BpIRSAlA+RwYeWcjJOC71eFQrhv1Dt3gLoHNgKNsUk+RdVWKuiLy0upBdYgvY1V9
# HlRalVnK2TSBwF9e9nq1MIIFFzCCA/+gAwIBAgIQY8lRDV5ytYwQkGMocMB4oTAN
# BgkqhkiG9w0BAQUFADCBtDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWdu
# LCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQL
# EzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAo
# YykwNDEuMCwGA1UEAxMlVmVyaVNpZ24gQ2xhc3MgMyBDb2RlIFNpZ25pbmcgMjAw
# NCBDQTAeFw0wNzA1MjIwMDAwMDBaFw0wOTA2MDcyMzU5NTlaMIHaMQswCQYDVQQG
# EwJOTDEWMBQGA1UECBMNTm9vcmQgQnJhYmFudDESMBAGA1UEBxMJRWluZGhvdmVu
# MR4wHAYDVQQKFBVHZXRyb25pY3MgUGlua1JvY2NhZGUxPjA8BgNVBAsTNURpZ2l0
# YWwgSUQgQ2xhc3MgMyAtIE1pY3Jvc29mdCBTb2Z0d2FyZSBWYWxpZGF0aW9uIHYy
# MR8wHQYDVQQLFBZNYW5hZ2VkIEluZnJhc3RydWN0dXJlMR4wHAYDVQQDFBVHZXRy
# b25pY3MgUGlua1JvY2NhZGUwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMb3
# KfnXifXVuOW8+B3OEptbBt+2iFshnWmBOrBN0tD8U5LT/jUAbLNKJyyB0ixoUX89
# R/9C73sz/pt+kJ3tAHuPvkXjpVh1Sk/A+qc0lj2k2vJUl2jjTQ05eK5DvzuKvj5+
# i/ZLt/xUAu2uzNHxXWOmo5ICOT+VU+QL6LQhMW+jAgMBAAGjggF/MIIBezAJBgNV
# HRMEAjAAMA4GA1UdDwEB/wQEAwIHgDBABgNVHR8EOTA3MDWgM6Axhi9odHRwOi8v
# Q1NDMy0yMDA0LWNybC52ZXJpc2lnbi5jb20vQ1NDMy0yMDA0LmNybDBEBgNVHSAE
# PTA7MDkGC2CGSAGG+EUBBxcDMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LnZl
# cmlzaWduLmNvbS9ycGEwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdQYIKwYBBQUHAQEE
# aTBnMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wPwYIKwYB
# BQUHMAKGM2h0dHA6Ly9DU0MzLTIwMDQtYWlhLnZlcmlzaWduLmNvbS9DU0MzLTIw
# MDQtYWlhLmNlcjAfBgNVHSMEGDAWgBQI9VHo+/49PWQ2fGjPW3io37nFNzARBglg
# hkgBhvhCAQEEBAMCBBAwFgYKKwYBBAGCNwIBGwQIMAYBAQABAf8wDQYJKoZIhvcN
# AQEFBQADggEBACHu4l8ozi7Q58IKjLWvIjPdeNRDI0Zz6V4NvSbxqyu8nOMswHAY
# yozN+8wVyZ9gyv74mjKj8LButEUp1pKmxEb0kGJN3sndD7G3UH7KJKCIsy9oUSfX
# 4FpBjQ48R7IkcEysysxzQ0Oc1iWUZEX6+MU2kMUVxgHSph5Duc5uV9UmYAKOo2Po
# mGWMdN1am0CkrTPW5hP6THLpZmuUBy+2++yl97j/wCemqLH2GaYRf8Ovo8CW/RkK
# Q+wWbYg3n0DtFpqKr1a+FE9PfbNm/Pt1Ob38gCGlyTvez+RgBTWlCjYkmsC0DDVn
# nZqhySerWzADCRkAAEFsj7zhLvZXtgjI378xggPHMIIDwwIBATCByTCBtDELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJp
# U2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0
# cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykwNDEuMCwGA1UEAxMlVmVyaVNp
# Z24gQ2xhc3MgMyBDb2RlIFNpZ25pbmcgMjAwNCBDQQIQY8lRDV5ytYwQkGMocMB4
# oTAJBgUrDgMCGgUAoIHSMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTZrtJ38fVN
# DNUTdu1HOeo/Irt7HTByBgorBgEEAYI3AgEMMWQwYqAggB4ATgBGAGkAbgBpAHQA
# eQAgAHMAYwByAGkAcAB0AHOhPoA8aHR0cHM6Ly9jb25uZWN0LmdldHJvbmljcy5j
# b20vc2l0ZXMvRlBXL1Byb2dyYW0vZGVmYXVsdC5hc3B4MA0GCSqGSIb3DQEBAQUA
# BIGAoUa2REGT1AorjUPg2lkSWyanXjoIOMIZtyZ1+RIvHcNWb3mACjvJePN4koVP
# N2eVBgbVTKg4EoDQq6zf5DUd/0ugbaUf2Py4Vnxmj3v5nyTr6wQODJhORSoM1Z34
# ezrexPOQ9M1QR0i/23evWTN3+0QUeMpMmJ01FtpsxN7mYTmhggF+MIIBegYJKoZI
# hvcNAQkGMYIBazCCAWcCAQEwZzBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVy
# aVNpZ24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2Vy
# dmljZXMgQ0ECEDgl1/r4Ya+e9JDnJrXWWtUwDAYIKoZIhvcNAgUFAKBZMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA4MDMxNDEzMTgy
# MVowHwYJKoZIhvcNAQkEMRIEEA2bSoqMIPan2YnRpxweSacwDQYJKoZIhvcNAQEB
# BQAEgYCn22L0BEb2rkNqjZpIt/88HwNuqT+xBguvLDSOzcgnjV/r6VEAov9PPK/E
# W82VLl+cELxaMSCYtZRgNqV1nV7Q4PekYeHa6s2KzNYDhEFJNrUn9jneKAP+Db1I
# gWWtesyETufPhNBdljibmLeD6aYvyVdf5U8bSI7Sbk/aZ/OY8g==
# SIG # End signature block
