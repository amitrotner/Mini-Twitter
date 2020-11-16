<template>
    <div class="jumbotron.bg-light text-black text-center">
        <div class="container-fluid">
            <div class="row">
                <div class="mx-auto pt-5" >
                    <img src="https://storage.googleapis.com/tweets-and-profile-pics/twitter-logo-mask.jpg" width="250" height="250">
                    <router-view></router-view>
                    <br>
                    <div v-if="alert.message" :class="`alert ${alert.type}`">{{alert.message}}</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { mapState, mapActions } from 'vuex'
import Vue from 'vue'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'

// Install BootstrapVue
Vue.use(BootstrapVue)
// Optionally install the BootstrapVue icon components plugin
Vue.use(IconsPlugin)


export default {
    name: 'app',
    computed: {
        ...mapState({
            alert: state => state.alert
        })
    },
    methods: {
        ...mapActions({
            clearAlert: 'alert/clear' 
        })
    },
    watch: {
        $route (to, from){
            // clear alert on location change
            this.clearAlert();
        }
    } 
};
</script>

<style>
img {
  border-radius: 50%;
}

</style>