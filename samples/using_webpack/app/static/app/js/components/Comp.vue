<template>
	<h1>This is my {{name}} component.</h1>
</template>

<script>
export default {
	data() {
		return {
			name: 'cool',
		}
	}
}
</script>

<style scoped>
	* {
		background-color: green;
	}
</style>
