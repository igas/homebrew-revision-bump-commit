#:  * `revision-bump-commit`
#:  Add revision bump commit
#:
#:  `brew revision-bump-commit <reason_formula> <formula_to_bump>`

REVISION_BUMP_COMMIT_PATH = Pathname.new(__FILE__).realpath/".."/".."

$LOAD_PATH.unshift(REVISION_BUMP_COMMIT_PATH)

reason_formula = ARGV.formulae[0]
formula_to_bump = ARGV.formulae[1]

if formula_to_bump.revision.nonzero?
  Utils::Inreplace.inreplace(formula_to_bump.path) do |s|
    s.gsub!(
      /^  revision \d+\n(\n(  head "))?/m,
      "  revision #{formula_to_bump.revision + 1}\n\\2",
    )
  end
else
  Utils::Inreplace.inreplace(formula_to_bump.path) do |s|
    s.gsub!(
      /^(  sha256 ".+")$/,
      "\\1\n  revision 1",
    )
  end
end

safe_system "git",
            "commit",
            "--no-edit",
            "--verbose",
            "--message=#{formula_to_bump.name}: revision bump for #{reason_formula.name}",
            "--",
            formula_to_bump.path
