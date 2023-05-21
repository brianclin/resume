import { generate } from "critical";
import gulp from "gulp";

gulp.task("critical", () => {
  return generate({
    inline: true,
    base: "terraform/",
    src: "index.html",
    target: "index-critical.html",
    width: 1300,
    height: 900,
  });
});
