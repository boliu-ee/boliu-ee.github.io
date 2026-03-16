# Bilingual Personal Website Starter Template

This template is designed for GitHub Pages and Gitee Pages.

## What changed in this version

There is **no standalone language selection page** anymore.

Instead:
- Chinese home ↔ English home
- Chinese resume ↔ English resume
- Chinese projects ↔ English projects
- Chinese blog ↔ English blog
- Each Chinese article ↔ its paired English article

## Directory structure

- `zh/` Chinese pages
- `en/` English pages
- `assets/css/` shared stylesheet
- `resume/` place your PDF resumes here

## Deployment

### GitHub Pages
For a user site, create a repository named:

`your-github-username.github.io`

Then upload all files to the repository root, go to:

`Settings -> Pages`

and choose:
- Source: Deploy from a branch
- Branch: main
- Folder: /(root)

### Gitee Pages
Create a repository, upload the same files, then enable Pages in the repository service settings.

## Recommended maintenance strategy

When you create a new post:
1. Create `zh/posts/post-xxx.html`
2. Create `en/posts/post-xxx.html`
3. Add links between them
4. Add the new post to both `zh/blog.html` and `en/blog.html`

## Suggested next step

Replace placeholder content with your real:
- name
- bio
- education
- selected projects
- resume PDF
- first bilingual blog post
