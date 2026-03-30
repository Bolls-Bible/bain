/**
 * Compute search relevance score for a string.
 * 
 * @param {string} text
 * @param {string} query
 * @returns {number} score
 */
export function scoreSearch(text, query) {
  if (!text || !query) {
    return 0;
  }

  let searchText = text.toLowerCase();
  let score = 0;
  let p = 0; // Position within the `text`
  let consecutiveBonus = 2; // Bonus for consecutive matches

  // Here is the main magic
  // Look through each character of the queryText string, stopping at the end(s)...
  let queryLength = query.length;
  for (let i = 0; i < queryLength; i += 1) {
    // Figure out if the current letter is found in the rest of the `text`.
    let index = searchText.indexOf(query[i], p);
    // If not, continue to the next character.
    if (index < 0) {
      // If the character is not found after p, check if it is found before p
      // Because we are jumping over the characters, we need to check if the character is found before p
      index = searchText.indexOf(query[i]);
      if (index < 0) continue;
    }
    //  If it is, add to the score...
    score += 1;
    // If the character is found in the next two chars, give it a bonus for being consecutive
    if (index - p < 2) {
      score += consecutiveBonus;
      // if the char is next, multiply the bonus by 2
      if (index === p) consecutiveBonus *= 2;
      // Otherwise, don't reset the bonus, maybe user missed a char
    } else {
      consecutiveBonus = 2;
    }
    //  ... and skip the position within `text` forward.
    p = index + 1;
  }

  // bonus for exact match & similar length
  if (
    searchText.includes(query) &&
    Math.abs(searchText.length - query.length) < 2
  ) {
    score += 2;
  }

  // filter by relative threshold
  if (score >= query.length * 2) {
    return score;
  }
  return 0;
}
