# QA Checklist - Release 0.0.12

## Pre-Release Smoke Test

### Authentication

- [ ] User can register with valid email/password
- [ ] User cannot register with duplicate email
- [ ] User can login with valid credentials
- [ ] User cannot login with invalid credentials
- [ ] Login redirects to welcome page on success

### API Endpoints

- [ ] GET /healthz returns 200 and {status: "ok"}
- [ ] GET /v1/secret returns 401 without token
- [ ] GET /v1/secret returns 200 with valid token
- [ ] GET /v1/secret returns user ID in response

### Frontend UI

- [ ] Login form validation works
- [ ] Error messages display properly
- [ ] Loading states show during API calls
- [ ] Token is displayed on welcome page
- [ ] Logout functionality works

### Containerization

- [ ] Docker images build successfully
- [ ] docker-compose up brings up all services
- [ ] Services are accessible on expected ports
- [ ] Inter-service communication works

### Security

- [ ] No sensitive data in logs
- [ ] CORS headers properly configured
- [ ] Authentication tokens are validated
- [ ] No hardcoded credentials

## Performance & Compatibility

### Cross-Browser (if applicable)

- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)

### Responsive Design

- [ ] Mobile view (320px+)
- [ ] Tablet view (768px+)
- [ ] Desktop view (1024px+)

## Documentation

- [ ] README.md updated and accurate
- [ ] API endpoints documented
- [ ] Setup instructions clear
- [ ] Troubleshooting section included

---

**Checklist Executed By**: ********\_\_\_\_********  
**Date**: ********\_\_\_\_********  
**Release Version**: 0.0.12  
**Status**: ✅ Ready for Release / ⚠️ Issues Found / ❌ Blocked
