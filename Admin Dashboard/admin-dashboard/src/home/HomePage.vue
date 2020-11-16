<template>
  <div>
    <br>
    <h3>Mini Twitter</h3>
    <h4>Admin Dashboard</h4>
    <p>
      <router-link to="/login">Logout</router-link>
    </p>
    <br />
    <em v-if="users.loading">Loading users...</em>
    <span v-if="users.error" class="text-danger">ERROR: {{ users.error }}</span>
        <div class="table-wrapper">
          <div class="table-title">
                <h2>User Management</h2>
          </div>
          <div class="serv">
          <ul v-if="users.items">
            <li
              v-for="user in users.items"
              :key="user.UserName"
              style="list-style: none"
            >
              <table class="table table-striped table-hover">
                <tbody>
                  <tr>
                    <td>
                      <img
                        :src="user.ProfilePicPath"
                        height="64"
                        width="64"
                        alt="Image"
                      />
                    </td>
                    <td class="user">{{ user.UserName }}</td>
                    <td class="mail">{{ user.Email }}</td>
                  </tr>
                </tbody>
              </table>
            </li>
          </ul>
          </div>
        </div>
      </div>
</template>

<script>
import { mapState, mapActions } from "vuex";

export default {
  computed: {
    ...mapState({
      account: (state) => state.account,
      users: (state) => state.users.all,
    }),
  },
  created() {
    this.getAllUsers();
  },
  methods: {
    ...mapActions("users", {
      getAllUsers: "getAll",
    }),
  },
};
</script>

<style>
body {
  font-family: "Varela Round", sans-serif;
  font-size: 16px;
  text-align: center;
}

.table-wrapper {
  min-width: 500px;
  background: #fff;
  padding: 20px 25px;
  border-radius: 3px;
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.05);
}

.table-title {
  padding-bottom: 15px;
  background: #299be4;
  color: #fff;
  padding: 16px 30px;
  margin: -20px -25px 10px;
  border-radius: 3px 3px 0 0;
}

.table-title h2 {
  margin: 5px 0 0;
  font-size: 24px;
}

table.table-striped tbody tr:nth-of-type(odd) {
  background-color: #fcfcfc;
}
table.table-striped.table-hover tbody tr:hover {
  background: #f5f5f5;
}
table.table .avatar {
  border-radius: 50%;
  vertical-align: middle;
  margin-right: 10px;
}

.serv ul {
  display: flex;
  flex-wrap: wrap;
  padding-left: 0;
}

.serv ul li {
  list-style: none;
  flex: 0 0 33.333333%;
}

.user {
  width: 300px;
  height: 100px;
  text-align: left;
}

.mail {
  width: 300px;
  height: 100px;
  text-align: left;
}
</style>