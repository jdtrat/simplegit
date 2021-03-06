
#' Create a new repository
#'
#' @inheritParams gh_collab_invite
#' @param private Will this repository be private? TRUE/FALSE; default is TRUE.
#' @param description (Optional) A short description of the repository.
#'
#' @return NA; used for side effects to create a repository on GitHub.
#' @export
#' @family Repositories
#'
gh_repos_create <- function(path, private = TRUE, description = NULL, ...) {

  path <- check_path(path)

  invisible(
    gh::gh("POST /user/repos",
         name = path[2],
         private = private,
         description = NULL,
         ...)
  )

}

#' List a user's github repository
#'
#' @inheritParams gh_repos_create
#' @param user The GitHub user
#'
#' @export
#'
#' @return Repositories for the specified user.
#' @family Repositories
#' @examples
#' gh_repos_list("jdtrat")

gh_repos_list <- function(user, ...) {

  repos <- gh::gh("GET /users/{username}/repos",
         username = user,
         ...)

  output <- jsonlite::fromJSON(
    jsonlite::toJSON(repos)
  )

  return(output)

}

#' Actually delete repo
#'
#' @param owner GitHub user
#' @param repo GitHub repo
#' @inheritParams gh_repos_create
#'
#' @return NA; used for side effects to delete a repository from GitHub.
#' @family Repositories
#'
#' @keywords internal
#'
gh_repos_delete_internal <- function(owner, repo, ...) {

  gh::gh("DELETE /repos/{owner}/{repo}",
         owner = owner,
         repo = repo,
         ...)

  cat(paste0("Okay, the ", repo, " repository was just deleted."))

}


#' Delete a GitHub repository
#'
#' \strong{Use with caution!} By default the github token created with [usethis::create_github_token()]
#' does not allow this functionality. You must create your own PAT that has the
#' appropriate permissions to delete repositories.
#'
#' @inheritParams gh_repos_create
#'
#'
#' @return NA; used for side effects to delete a repository from GitHub.
#' @export
#' @family Repositories
#'
gh_repos_delete <- function(path, ...) {

  path <- check_path(path)

  yes <- paste0("Yes, I want to permanently delete the ", path[2], " repository.")
  no <- paste0("No, I don't want to permanently delete the ", path[2], " repository.")
  no_2 <- paste0("Aw hell naw. I do NOT want to permanently delete the ", path[2], " repository.")

  switch(utils::menu(c(no, yes, no_2), title = paste0("Are you sure you want to permanently delete the ", path[2], " repository?")),
         cat(paste0("Noice, the ", path[2], " repository was not deleted.")),
         gh_repos_delete_internal(owner = path[1], repo = path[2], ...),
         cat(paste0("Your wish is my command. The ", path[2], " repository was not deleted.")))
}

#' Change repository features
#'
#' This function allows you to update a repository's features. You can easily
#' change the repository's name, privacy settings, and more.
#'
#' @inheritParams gh_repos_create
#'
#' @return NA; called for side effects to manipulate GitHub repositories.
#' @export
#' @family Repositories
#'
#' @examples
#'
#' \dontrun{
#'
#' # Create a Private Repo
#' gh_repos_create(path = "jdtrat/ghee_test", private = TRUE, description = "A test repository.")
#'
#' # Disable Issues
#' gh_repos_mutate(path = "jdtrat/ghee_test", has_issues = FALSE)
#'
#' # Update Description
#' gh_repos_mutate(path = "jdtrat/ghee_test", description = "A test repository for {ghee}.")
#'
#' # Remove Description
#' gh_repos_mutate("jdtrat/friend", description = NA)
#'
#' # Change Privacy Settings
#' gh_repos_mutate(path = "jdtrat/ghee_test", private = FALSE)
#'
#' # Change Repo Name
#' gh_repos_mutate(path = "jdtrat/ghee_test", name = "ghee_testing")
#'
#' # Change Repo Name Back
#' # Note the path argument reflects the name change
#' gh_repos_mutate(path = "jdtrat/ghee_testing", name = "ghee_test")
#'
#' # Delete Repo
#' # Note this requires a special GitHub Token and should be used with caution.
#' gh_repos_delete("jdtrat/ghee_test")
#'
#' }
#'
#'
gh_repos_mutate <- function(path, ...) {

  path <- check_path(path)

  invisible(
  gh::gh("PATCH /repos/{owner}/{repo}",
         owner = path[1],
         repo = path[2],
         ...)
  )
}


