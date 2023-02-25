export default defineNuxtRouteMiddleware((to, from) => {
  if (
    typeof to.query.platform === "string" &&
    typeof to.query.uid === "string"
  ) {
    const user = useCurrentUser();
    if (
      user.value?.platform !== to.query.platform ||
      user.value.uid !== to.query.uid
    ) {
      user.value = {
        platform: to.query.platform,
        uid: to.query.uid,
      };
    }
  }
});
