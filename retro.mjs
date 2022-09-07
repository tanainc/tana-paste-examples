import luxon from "luxon";
import { formatDate, nth } from "./helpers.mjs";

const DateTime = luxon.DateTime;

Date.prototype.getWeek = function () {
  var date = new Date(this.getTime());
  date.setHours(0, 0, 0, 0);
  // Thursday in current week decides the year.
  date.setDate(date.getDate() + 3 - ((date.getDay() + 6) % 7));
  // January 4 is always in week 1.
  var week1 = new Date(date.getFullYear(), 0, 4);
  // Adjust to Thursday in week 1 and count number of weeks from date to week1.
  return (
    1 +
    Math.round(
      ((date.getTime() - week1.getTime()) / 86400000 -
        3 +
        ((week1.getDay() + 6) % 7)) /
        7
    )
  );
};

const dateBack = (days) =>
  `[[${formatDate(DateTime.local().minus({ days }))}]]`;

const googleYears = new Array(6).fill("").map((_, i) => 2004 + i * 3);

const today = DateTime.local();
const month = today.month;
const day = today.day;
const tomorrow = today.plus({ days: 1 });
const tomorrowDay = tomorrow.day;

const seven = dateBack(7);
const ninety = dateBack(90);
const thirty = dateBack(30);
const hundredeighty = dateBack(180);
const threesixty = dateBack(360);
const seventwenty = dateBack(720);

const googleStrings = googleYears.map(
  (year) =>
    `(after:${year}/${month}/${day} before:${year}/${
      tomorrowDay < day ? month + 1 : month
    }/${tomorrowDay})`
);

const myemail = "peter@gmail.com";
const googleSearch = `(${googleStrings.join(" OR ")}) AND from:${myemail}`;
const googleUrl = `https://mail.google.com/mail/u/0/#search/${encodeURIComponent(
  googleSearch
)
  .split("(")
  .join("%28")
  .split(")")
  .join("%29")}`;

console.log(
  `%%tana%%
- Retro
  -  ${seven}
  -  ${thirty}
  -  ${ninety}
  -  ${hundredeighty}
  -  ${threesixty}
  -  ${seventwenty}
  -  [Gmail retro](${googleUrl})`
);
