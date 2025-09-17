## 수동 Runner 등록 방법
---

수동으로 GA Runner 등록하는 방법을 소개합니다. 이 방법은 야매이니, 모든 풀이 시도가 실패하여 시간이 촉박할 때만 사용하시기 바랍니다.
<br />
<조건>  
과제지에서는 dev, prod 각각 2개, 총 4개의 Runner가 등록되어 있어야 한다고 과제지에 명시하고 있습니다. 단, 이 부분은 과제수정으로 인해 변경될 수 있으니 유의해야 합니다.  
또한, 사용하는 토큰은 `ghp_`로 시작하는 Classic 토큰을 사용하여야 합니다. 권한은 전체 권한 부여하는 것이 편합니다.  
Token renew 명령어를 통해 발급된 Runner token을 `manual-<env>.yaml`의 RUNNER_TOKEN의 value로 사용합니다.
<br />
<프로비저닝>
- GITHUB_TOKEN : Github Classic Token을 사용하시기 바랍니다. 가능하면 권한은 전체 권한을 부여하는 것이 좋습니다.
- RUNNER_REPO : <username>/<reponame> 형식으로 작성합니다. skills-user/day2-product와 같은 형태로 작성합니다.
- RUNNER_TOKEN : 아래 Token renew 명령어를 통해 나온 값을 사용합니다. 이 값은 재사용될 수 없고, Runner를 등록할 때마다 서로 다른 값을 사용해야 합니다. 
- RUNNER_NAME : 등록할 Runner의 이름입니다. <dev/prod>-runner-<random5>-<random5>와 같은 형식으로 이름을 작성합니다.
- RUNNER_LABELS : 해당 값은 "dev,self-hosted,Linux,X64", "prod,self-hosted,Linux,X64" 중 하나로 작성해야 합니다.
- RUNNER_WORKDIR : 해당 값은 "/runner/_work"로 고정합니다.

### Token renew 명령어
```sh
curl -X POST \                                                                                          
  -H "Authorization: token <github_token>" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/<UserName>/day2-product/actions/runners/registration-token
```