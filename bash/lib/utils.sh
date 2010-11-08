# set up proxy for http_proxy ENV variable
function proxy ()
{
	echo -n "Proxy password: ";
	read -es password;
	echo;
	export http_proxy="http://$userid:$password@$proxy:$port/";
}
