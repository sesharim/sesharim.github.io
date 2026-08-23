# AI Engineering Positioning — Review Changelog

**Branch:** `feature/ai-engineering-positioning`  
**Scope:** Site positioning, landing pages, navigation, and metadata. Existing blog article bodies are unchanged.

The numbering below is the stable review contract. Removed recommendations leave a gap rather than renumbering later points. A request such as “remove point 8” refers to the complete scope documented under **8. Vocabulary consistency**.

## 1. Homepage positioning

**Done**
- Replaced the name-led eyebrow with `Software Engineering / AI Development`.
- Changed the H1 to position the site around reliable software systems and AI-assisted engineering workflows.
- Reworked the introduction to cover Rails, Go, backend systems, AI-powered products, RAG, MCP, contracts, and verification.
- Preserved the existing experience and credibility statements.

**Files**
- `index.html`

**Remove point 1**
- Revert the homepage hero, lead, and positioning copy while leaving the navigation and pillar cards intact.

## 2. Site metadata

**Done**
- Changed the site identity from the generic `Software Engineering consultant` title to `lukin.io`.
- Added `Software Engineering & AI Development` as the topic tagline, keeping the domain as the site name and the keywords as the positioning.
- Replaced the Rails/Go-only description with software engineering plus AI-development positioning.
- Added author and social identity metadata for structured output without making the author name the search target.
- Repositioned the blog landing-page title, description, H1, and introduction around software engineering and AI development.

**Files**
- `_config.yml`
- `blog.html`

**Remove point 2**
- Restore the previous `_config.yml` title/description and the previous generic Blog title/introduction.

## 3. Dedicated AI landing page

**Done**
- Added `/ai-development/` as a topic hub.
- Covers coding-agent workflows, RAG and semantic systems, MCP/tool integration, context, contracts, and verification.
- Documents the operating model: contract → context → plan → implementation → verification.
- Links to the main AI-development case studies and guides.

**Files**
- `ai-development.html`

**Remove point 3**
- Delete `ai-development.html` and remove links to `/ai-development/` from navigation and related-page sections.

## 4. Agents project page

**Done**
- Added `/projects/agents/` as the product/project page for `lukin-io/agents`.
- Explains `AGENTS.md`, `verify → bin/verify`, `contract_audit → bin/contract_audit`, documentation templates, and the expected workflow.
- Links the open-source implementation to the case study and relevant framework articles.

**Files**
- `agents.html`

**Remove point 4**
- Delete `agents.html` and remove links to `/projects/agents/` from navigation, homepage cards, and pillar pages.

## 5. Navigation

**Done**
- Homepage navigation now prioritizes internal destinations:
  - AI Development
  - Software Engineering
  - Agents Project
  - Blog
- External identity/contact links remain available after the topic links.
- Footer navigation exposes both pillars, the Agents project, Blog, and RSS on every page.
- Blog navigation links to both pillars and the project.

**Files**
- `index.html`
- `_includes/footer.html`
- `blog.html`

**Remove point 5**
- Restore the former homepage/footer/blog navigation while leaving the landing pages available by direct URL.

## 6. Two semantic pillars

**Done**
- Added the two primary homepage topic cards:
  - AI Development
  - Software Engineering
- Added `/software-engineering/` for Rails, Go, APIs, PostgreSQL, testing, performance, and backend architecture.
- Cross-linked the software-engineering and AI-development pillars so AI remains an extension of the engineering foundation.

**Files**
- `index.html`
- `software-engineering.html`
- `ai-development.html`

**Remove point 6**
- Delete `software-engineering.html`, remove the two homepage pillar cards, and remove pillar cross-links.

## 8. Vocabulary consistency

**Canonical terms**
1. `AI-assisted software development`
2. `agentic development`
3. `coding agents`
4. `context engineering`
5. `verification-driven development`

**Done**
- Standardized these terms across site metadata and the main non-article landing pages.
- Used the terms as a coherent positioning vocabulary rather than interchangeable AI buzzwords.
- Kept `software engineering` as the parent discipline and AI development as the specialization.

**Files**
- `_config.yml`
- `index.html`
- `blog.html`
- `ai-development.html`
- `software-engineering.html`
- `agents.html`

**Remove point 8**
- Remove the explicit five-term standardization from those files while preserving the pages, navigation, and broader software-engineering/AI-development positioning.
