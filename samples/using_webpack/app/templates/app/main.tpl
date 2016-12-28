{%  load render_bundle from webpack_loader %}
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
</head>
<body>
<div id='app'>
<input v-model='stuff' placeholder='Enter some text here'>
<p>${ stuff }</p>
</div>
{% render_bundle 'main' %}
</body>
</html>
