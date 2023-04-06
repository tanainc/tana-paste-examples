import fetch from "isomorphic-fetch";
import { config } from "./config.mjs";

const HIGHLIGHTS_URL = "https://readwise.io/api/v2/export/?";

const getItemsFromReadwise = async (daysToFetch = 1) => {
  let nextPageCursor = null;

  while (true) {
    const queryParams = new URLSearchParams();
    const dateOffset = 24 * 60 * 60 * 1000 * daysToFetch;
    const updatedAfterDate = new Date();
    updatedAfterDate.setTime(updatedAfterDate.getTime() - dateOffset);

    if (nextPageCursor) {
      queryParams.append("pageCursor", nextPageCursor);
    }
    if (updatedAfterDate) {
      queryParams.append("updatedAfter", updatedAfterDate.toISOString());
    }
    const response = await fetch(`${HIGHLIGHTS_URL + queryParams.toString()}`, {
      headers: {
        Authorization: `Token ${config.readwiseToken}`,
      },
    });

    const data = await response.json();
    nextPageCursor = data.nextPageCursor;

    data.results.forEach((book) => {
      const isValidSourceURL = book.source_url?.startsWith("https://");
      const hasHighlights = book.highlights?.length > 0;

      console.log(`- ${book.title} #from-the-web`);
      if (isValidSourceURL) {
        console.log(`  - URL:: ${book.source_url}`);
      }
      console.log(`  - type:: ${book.category?.replace(/s$/, "")}`);
      console.log(`  - author:: ${book.author}`);
      if (hasHighlights) {
        console.log(`  - Highlights`);
      }

      book.highlights.forEach((highlight) => {
        const lines = highlight.text.split("\n");
        lines.forEach((line) => {
          const cleanedLine = line.replace(/•\s+/, "").trim();
          if (cleanedLine.length > 0) {
            console.log(`    - ${cleanedLine}`);
          }
        });

        if (highlight.note) {
          console.log(`      - ${highlight.note}`);
        }
      });
    });
    if (nextPageCursor == null) {
      break;
    }
  }
};

const daysToFetch = process.argv[2];
console.log(`%%tana%%`);
getItemsFromReadwise(daysToFetch);
