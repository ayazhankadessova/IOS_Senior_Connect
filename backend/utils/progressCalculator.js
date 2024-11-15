exports.calculateAverageQuizScore = (progress) => {
  const allScores = Object.values(progress)
    .flat()
    .flatMap((lesson) => lesson.quizScores.map((q) => q.score))

  if (allScores.length === 0) return 0

  return parseFloat(
    (
      allScores.reduce((sum, score) => sum + score, 0) / allScores.length
    ).toFixed(2)
  )
}
