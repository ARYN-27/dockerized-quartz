## Providing Quartz

This container supports three methods for providing your Quartz instance. You can use the default Quartz repository, pull a custom repository, or bring your own Quartz (BYOQ). Below are the details for each approach.

### 1. Auto-Pull of the Default Quartz Repository

By default, if no specific repository is provided, the container will automatically pull the main [Quartz repository](https://github.com/jackyzha0/quartz.git) on startup. This option is ideal for quickly deploying a base Quartz setup. However, since the repository is not stored in a persistent volume, you will not be able to customize the Quartz files.

### 2. Pulling a Custom Repository

To use your own custom Quartz repository, simply set the `GIT_REPO` environment variable to the URL of your desired repository. The container will pull this custom repository during startup. If no Docker volume is mounted for Quartz, the repository will be pulled fresh every time the container restarts.

**Environment Variable**:
- `GIT_REPO=<your-custom-repo-url>`

### 3. Bring Your Own Quartz (BYOQ)

If you already have a Quartz setup on your host, you can bring it into the container using a bind mount. This allows you to persist and fully control your Quartz files outside of the container.

Alternatively, you can set the `GIT_REPO` environment variable to pull the repository into a mounted volume during the first run. Once the Quartz repository is inside the volume, you are responsible for maintaining and updating it manually as needed.

The path of Quartz in container is `/usr/src/app/quartz`.

### 3.1 Pulling from private Github repo

To pull Quartz from a private GitHub repository, follow these steps:

1. **Create a Personal Access Token (PAT)**:
   - Navigate to your GitHub profile.
   - Click on **Settings**.
   - Go to **Developer Settings**.
   - Select **Personal Access tokens**.
   - Click on **Generate new token** and follow the instructions to create your token.

2. **Choose the Token Type**:
   - Both **Fine-grained** and **Tokens (classic)** should work for accessing your private repository. Ensure that the token has the necessary permissions to read the repository.

3. **Set the `GIT_REPO` Environment Variable**:
   - Use the following format to set the `GIT_REPO` environment variable:
     ```
     https://<github_token>@github.com/<github_username>/<your_quartz_repo_name>.git
     ```
   - Replace `<github_token>` with your generated Personal Access Token, `<github_username>` with your GitHub username, and `<your_quartz_repo_name>` with the name of your Quartz repository.

With these steps completed, the container will automatically pull your private Quartz repository on startup.