# Checklist before deploys

- Work is done on a branch name following the next pattern: 'feature/**'
- Update service worker version
- Get dev deployed working
- If the deploy is successful -- merge it to master and tag it with a new version tag (vX.X.X)

And do not forget to clean expired sessions sometimes

```bash
python manage.py clearsessions
```