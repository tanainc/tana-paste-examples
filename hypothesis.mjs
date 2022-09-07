import queryString from "query-string";
import fetch from "isomorphic-fetch";
import lodash from "lodash";
import querystring from "querystring";

import { formatDate } from "./helpers.mjs";
import { config } from "./config.mjs";

const parseAnnotation = (a) => {
  const textRaw = a.text;
  const quotationRaw =
    lodash.get(a, "target[0]selector") &&
    a.target[0].selector.find((x) => x.exact) &&
    a.target[0].selector.find((x) => x.exact).exact;
  const quotation = (quotationRaw || "").replace(/\n/g, " ");
  const text = (textRaw || "").replace(/\n/g, " ");
  const extraIndent = text ? "  " : "";
  const quoteString = quotation ? `    - ${quotation}` : "";
  const textString = text ? extraIndent + `    - ^^${text}^^` : "";
  return [quoteString, textString].join("\n");
};

const getAnnotations = async (token, annotatedUrl, user) => {
  const pdfUrl = annotatedUrl.match(/viewer.html\?file=(.+)$/);
  if (pdfUrl) {
    annotatedUrl = Object.keys(querystring.decode(pdfUrl[1]))[0];
  }
  const query = queryString.stringify({
    limit: 200,
    url: annotatedUrl,
    user,
  });
  const url = "https://hypothes.is/api/search?" + query;
  const queryHeaders = token && {
    headers: {
      Authorization: "Bearer " + token,
    },
  };
  try {
    await fetch(url, queryHeaders)
      .then((e) => e.json())
      .then((e) => {
        const article = lodash.get(e, "rows[0].document.title[0]");
        const updated = lodash.get(e, "rows[0].updated");
        const annotations = lodash
          .orderBy(e.rows, (f) => {
            try {
              return lodash
                .get(f, "target[0].selector")
                .filter((x) => x.type === "TextPositionSelector")[0].start;
            } catch (e) {
              return 0;
            }
          })
          .map((x) => parseAnnotation(x))
          .join("\n");
        const dateStr = formatDate(updated);
        console.log(
          `- ${article} #article
  - Source:: ${annotatedUrl}\n
  - Updated:: ${dateStr}\n
  - Annotations
${annotations}`
        );
      });
  } catch (e) {
    console.error(e);
  }
};

console.log("%%tana%%");
getAnnotations(config.hypothesisToken, process.argv[2].trim());
