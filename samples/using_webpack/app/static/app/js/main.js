import Vue from 'vue';
import Comp from './components/Comp.vue';

var app = new Vue({
	el: '#app',
	components: {
		'my-comp': Comp,
	},
	delimiters: ['${', '}'],
});
