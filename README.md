# Event Store Documentation

**This documentation is available at <http://docs.getprooph.org/>.** Pages are built with [DocFX](https://dotnet.github.io).

What follows is documentation for how to use and contribute to the Event Store documentation. If you’re planning to make updates or contributions then read on. Otherwise, head on over to the [website](http://docs.getprooph.org/).

### Documentation Theme

If you would like to improve the theme for the documentation site, then you can find its repository [here](https://github.com/prooph/docs-template).

### Running DocFX Locally

You can generate the site locally and test your changes. Follow the instructions [here](https://dotnet.github.io/docfx/tutorial/docfx_getting_started.html) to install DocFX and dependencies, then run:

```bash
docfx build docfx.json --serve
```

This builds the site to the `/_site` folder and serves it at `http://localhost:8080`.

### Running DocFX with Docker

Assuming you have a directory `~/code/prooph` with 2 repositories there `documentation` and `docs-template`:

```bash
docker run -itv ~/code/prooph/:/tmp tsgkadot/docker-docfx:latest docfx build /tmp/documentation/docfx.json
```

### Small Edits

1.  Make changes (fix typos or grammar, improve wording etc).
2.  Send a pull request!

### New Pages and Sections

1.  Create new pages and/or sections. Follow the [Conventions](#conventions) below.
2.  If you create a new section add an entry for it to the _toc.md_ file. This file determines the order of sections in the navigation sidebar and helps DocFX build internal navigation.
3.  Send a pull request!

## Conventions

### File Names

-   File and directory names are all lowercase.
-   Replace spaces with dashes.
-   Markdown files take the `.md` extension.

### Formatting and Typesetting

The content of our documentation has multiple authors. Formatting and style guidelines help maintain a consistent use of language throughout the docs.

-   **Acronyms and abbreviations**: Use uppercase (e.g. API, HTTP, PHP)
-   **Brand names**: Use correct typesetting (e.g. cURL, Event Store)
-   **Example code** should not have a line length of more than 80 characters
