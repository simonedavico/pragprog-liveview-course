defmodule LiveviewStudioWeb.ReposLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.GitRepos

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      language: "",
      license: "",
      repos: GitRepos.list_git_repos()
    )
    {:ok, socket, temporary_assigns: [repos: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Trending Git Repos</h1>
    <div id="repos">

      <form phx-change="update-filters">
        <div class="filters">
          <select name="language">
            <%= options_for_select([All: "", Elixir: "elixir", Ruby: "ruby"], @language) %>
          </select>

          <select name="license">
            <%= options_for_select([All: "", Apache: "apache", MIT: "mit", BSDL: "bdsl"], @license) %>
          </select>
        </div>
      </form>

      <div class="repos">
        <ul>
          <%= for repo <- @repos do %>
            <li>
              <div class="first-line">
                <div class="group">
                  <img src="images/terminal.svg">
                  <a href={repo.owner_url}>
                    <%= repo.owner_login %>
                  </a>
                  /
                  <a href={repo.url}>
                    <%= repo.name %>
                  </a>
                </div>
                <button>
                  <img src="images/star.svg">
                  Star
                </button>
              </div>
              <div class="second-line">
                <div class="group">
                  <span class={"language #{repo.language}"}>
                    <%= repo.language %>
                  </span>
                  <span class="license">
                    <%= repo.license %>
                  </span>
                  <%= if repo.fork do %>
                    <img src="images/fork.svg">
                  <% end %>
                </div>
                <div class="stars">
                  <%= repo.stars %> stars
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("update-filters", %{"language" => language, "license" => license}, socket) do
    params = [language: language, license: license]
    repos = GitRepos.list_git_repos(params)
    {:noreply, assign(socket, params ++ [repos: repos])}
  end

end
