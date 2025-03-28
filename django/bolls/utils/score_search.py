def score_search(text: str, query: str) -> int:
    if not text or not query:
        return 0

    search_text = text.lower()
    score = 0
    p = 0  # Position within the `text`
    consecutive_bonus = 2  # Bonus for consecutive matches

    query_length = len(query)
    for i in range(query_length):
        index = search_text.find(query[i], p)
        if index < 0:
            index = search_text.find(query[i])
            if index < 0:
                continue

        score += 1
        if index - p < 2:
            score += consecutive_bonus
            if index == p:
                consecutive_bonus *= 2
        else:
            consecutive_bonus = 2

        p = index + 1

    if query in search_text:
        score += 2

    if score >= len(query):
        return score

    return 0


# a few testcases
# print(score_search('sing', 'ED SH ing'))
# print(score_search("I Don't care", 'DON‘T CARE CHERYL'))
# print(score_search("Cheryl", 'DON‘T CARE CHERYL'))
# print(score_search('Good Enough', 'GOOD EN'))
# print(score_search('God Save the Queen', 'GOOD EN'))
# print(score_search('Del Shannon', 'ed shran'))
# print(score_search('Ed Sheeran', 'ed shran'))
