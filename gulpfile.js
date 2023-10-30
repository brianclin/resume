import { generate } from "critical";
import gulp from "gulp";
import dartSass from "sass";
import gulpSass from "gulp-sass";

const sass = gulpSass(dartSass);

gulp.task("critical", () => {
  return generate({
    inline: true,
    src: "index.html",
    target: "index-critical.html",
    width: 1300,
    height: 900,
  });
});

gulp.task("sass", () => {
  return gulp
    .src("./terraform/assets/**/*.scss")
    .pipe(sass().on("error", sass.logError))
    .pipe(gulp.dest("./terraform/assets/"));
});
