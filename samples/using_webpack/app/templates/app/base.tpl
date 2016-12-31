<!DOCTYPE html>
<html lang="en">

	<head>
		<meta charset="utf-8" />
		<title>Homework</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<link data-require="bootstrap-css" data-semver="4.0.0-alpha.4" rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.4/css/bootstrap.min.css" />
		<link data-require="bootstrap@*" data-semver="4.0.5" rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.5/css/bootstrap.min.css" />
		<style>
			body {
				padding-top: 60px;
			}
			@media (max-width: 979px) {

				/* Remove any padding from the body */
				body {
					padding-top: 0;
				}
			}
		</style>
		<script data-require="jquery" data-semver="3.0.0" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0/jquery.js"></script>
		<script data-require="tether" src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js"></script>
		<script data-require="bootstrap" data-semver="4.0.5" src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.5/js/bootstrap.min.js"></script>
	</head>
	<body>
		<div class="container">
		{% block content %}{% endblock %}
		</div>
{% block extra_js %}{% endblock %}
	</body>
</html>
