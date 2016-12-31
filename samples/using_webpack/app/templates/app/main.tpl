{% extends 'app/base.tpl' %}
{% load render_bundle from webpack_loader %}

{% block content %}
<div id='app'>
	<my-comp></my-comp>
</div>
{% endblock %}

{% block extra_js %}
{% render_bundle 'main' %}
{% endblock %}
