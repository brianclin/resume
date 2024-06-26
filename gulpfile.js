import { generate } from "critical";
import gulp from "gulp";
import * as dartSass from "sass";
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
    .src("./assets/**/*.scss")
    .pipe(sass().on("error", sass.logError))
    .pipe(gulp.dest("./assets/"));
});
