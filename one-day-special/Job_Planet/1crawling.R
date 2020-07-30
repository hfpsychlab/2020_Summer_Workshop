# R설치 "http://cran.r-project.org" (운영의 기본프로그램)
# R studio 설치 "http://www.rstudio.com/products/rstudio/download" (R 프로그램 실행을 지원하는 통합 툴 프로그램)
# 참고 사이트 "https://m.blog.naver.com/lcaomo/221902464026"

install.packages("tidyverse")

library(httr)
library(rvest)
library(tidyverse)

# 로그인 화면의 URI를 복사하여 URI 객체에 지정합니다.
URI <- 'https://www.jobplanet.co.kr/users/sign_in'

# 로그인 정보를 이용하여 HTTP 요청을 합니다. 
resp <- POST(url = URI,
             body = list('user[email]' = 'ceronf1020@hanmail.net',
                         'user[password]' = 'hfpsych123'))

# 응답 상태코드를 확인합니다. 200이면 정상입니다.
status_code(x = resp)
## [1] 200

# 쿠키만 수집하여 myCookies 객체에 할당합니다. 
# 앞으로 HTTP 요청할 때 myCookies를 활용하면 로그인 상태로 HTML을 받을 수 있습니다. 
myCookies <- set_cookies(.cookies = unlist(x = cookies(x = resp)))


# 수집할 기업명을 지정합니다.
compNm <- '삼성전자'

# 잡플래닛 웹 페이지에서 삼성전자 기업리뷰를 확인할 수 있는 URI을 복사하여 붙입니다.
# 분명 웹 브라우저에서는 '삼성전자'이라고 한글로 보였을 것입니다. 
# 그런데 RStudio로 붙여넣기 하면 이상한 코드로 바뀝니다. 이것은 'URL인코딩'입니다. 
# 한글은 사람이 읽을 수 있지만 컴퓨터는 읽지 못하므로 컴퓨터가 읽을 수 있도록 변환해준 것입니다. 
URI <- 'https://www.jobplanet.co.kr/companies/30139/reviews/%EC%82%BC%EC%84%B1%EC%A0%84%EC%9E%90'


# 쿠키를 이용하여 로그인 상태 가장하여 HTTP 요청을 합니다.
resp <- GET(url = URI, config = list(cookies = myCookies))

# 응답 상태코드를 확인합니다.
status_code(x = resp)

# 기업리뷰 수를 추출합니다. (2020년 07월 23일 기준 : 5149건)

reviewCnt <- resp %>% 
  read_html() %>% 
  html_nodes(css = 'li.viewReviews > a > span.num.notranslate') %>% 
  html_text() %>% 
  as.numeric()

# 결과를 출력합니다.
print(x = reviewCnt)
## [1] 5149

# 잡플래닛에 저장된 회사이름을 추출합니다.
resp %>% read_html() %>% html_node(css = 'h2.tit') %>% html_text()

# 기업리뷰가 포함된 가장 상위의 HTML 요소를 지정합니다. (5개만 추출됨)
items <- resp %>% read_html() %>% html_nodes(css = 'section.content_ty4')
length(x = items)
## [1] 5

# 회사코드와 리뷰코드를 추출합니다. (잡플래닛에서 부여)
items %>% html_attr(name = 'data-company_id')
## [1] "30139" "30139" "30139" "30139" "30139"

items %>% html_attr(name = 'data-content_id')
## [1] "1759527" "1758711" "1756417" "1756052" "1755739"

# 개별 기업리뷰 상단에 있는 직종구분, 재직상태, 근무지역, 등록일자를 추출합니다.

items %>% html_nodes(css = 'div.content_top_ty2 span:nth-child(2)') %>% html_text()
## [1]  "연구개발"  "생산/제조" "IT/인터넷" "생산/제조" "생산/제조"

items %>% html_nodes(css = 'div.content_top_ty2 span:nth-child(4)') %>% html_text()
## [1] "현직원" "현직원" "전직원" "현직원" "현직원"

items %>% html_nodes(css = 'div.content_top_ty2 span:nth-child(6)') %>% html_text()
## [1] "서울" "경기" "경기" "경기" "경기"

items %>% html_nodes(css = 'div.content_top_ty2 span.txt2') %>% html_text()
## [1] "2020. 07. 21" "2020. 07. 20" "2020. 07. 19" "2020. 07. 18" "2020. 07. 18"

# 개별 기업리뷰 왼쪽에 있는 별점(총점, 승진기회, 복지급여, 워라밸, 사내문화, 경영진)을 추출합니다.
# 꺽쇠 사이에 텍스트로 존재하는 대신 HTML 요소의 속성값으로 존재하고 있으며, 
# 'width:100%'와 같은 형태이므로 나중에 정규식을 활용하여 숫자만 추출해야 합니다.
items %>% html_nodes(css = 'div.star_score') %>% html_attr(name = 'style')
## [1] "width:80%;"  "width:60%;"  "width:100%;" "width:100%;" "width:60%;" 

items %>% html_nodes(css = 'dl dd:nth-child(3) div div') %>% html_attr(name = 'style')
## [1] "width:60%;"  "width:80%;"  "width:100%;" "width:80%;"  "width:80%;" 

items %>% html_nodes(css = 'dl dd:nth-child(5) div div') %>% html_attr(name = 'style')
## [1] "width:80%;"  "width:100%;" "width:100%;" "width:100%;" "width:80%;" 

items %>% html_nodes(css = 'dl dd:nth-child(7) div div') %>% html_attr(name = 'style')
## [1] "width:80%;"  "width:100%;" "width:40%;"  "width:80%;"  "width:60%;"

items %>% html_nodes(css = 'dl dd:nth-child(9) div div') %>% html_attr(name = 'style')
## [1] "width:80%;"  "width:100%;" "width:60%;"  "width:100%;" "width:40%;"

items %>% html_nodes(css = 'dl dd:nth-child(11) div div') %>% html_attr(name = 'style')
## "width:60%;"  "width:40%;"  "width:80%;"  "width:100%;" "width:40%;" 


# 개별 기업리뷰 오른쪽에 있는 내용(장점, 단점, 바라는점, 성장예상, 추천여부)을 추출합니다.
items %>% html_nodes(css = 'dl dd:nth-child(2) span') %>% html_text()

## [1] "위치가 서울, 워라벨 좋은편, 자율출퇴근제도, 식당밥 좋음, 높은 보수"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
## [2] "돈. 자부심( 외부사람들에게)   자괴감( 내부 상대적박탈감)"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
## [3] "역량을 쌓기 정말 좋습니다. 이 회사는 학사도 연구개발에 배치해주고 대학이나 학점도 별로 가리지 않습니다. 공평하게 뽑아서 역량향상의 기회를 제공하는 느낌입니다. 다만 워라밸은 찾기 힘듭니다. 물론 근무시간은 예전보다 많이 줄고 있지만, 성과 압박이나 업무량으로 인해 다들 얼굴이 어둡습니다. 이건 사업부 그리고 팀마다 다르긴 하겠죠. 역량을 쌓아서 떠나기 좋은 곳입니다. 그리고 복지나 연봉 괜찮습니다. 연봉이 높지만 사실 성과급이 큰 역할을 차지하고 계약은 크지 않습니다. 삼전보다 많이 주고 복지 좋은 곳도 많습니다. Skt나 기름집이라든가... 다만 사내 새마을금고에서 대출이 빵빵하게 나온다든가, 식당 퀄이 미쳤다든가 헬스장 시걸이 좋다든가 등은 다른 기업이 따라하기 힘든 점 같네요. 회사가 수원인 점이 안 좋다고 생각했으나 나중에 다시 보니 수원이 차라리 집 구하기도 좋았던 거 같아요. 짧게 다니고 이직했고 또 이직할 때 고민도 많았으나, 많은 걸 배웠고 이직한 곳에서도 삼전에서 배운 거 잘 써먹구 있습니다"
## [4] "연차와 월차를 마음대로 쓸 수가 있다. 그리고 복지와 혜택같은 게 많으며 나무랄 곳이 없습니다. 선배님들이 워낙 학력 상관없이 잘 대해줍니다."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
## [5] "경기도에 위치해서 접근성이 좋음, 기업의 네임 밸류는 최상"

items %>% html_nodes(css = 'dl dd:nth-child(4) span') %>% html_text()
## [1] "단기성과 위주의 연구조직으로 경력 커리어 관리가 쉽지 않음"                                                                                                                                                                                                                                                    
## [2] "내부적으로도 직군간 업무난도에대한 불만과 보여주기식정책이많음"                                                                                                                                                                                                                                               
## [3] "워라밸, 특히 업무의 양이 일부 직원과 부서에 너무 편중되어있고 신입 인력의 배치가 적재적소에 되는 느낌이 아닙니다. 부족한 부서는 언제나 부족합니다. 그리고 네임밸류에 비해 복지와 계약연봉이 작은 점은 조금 아쉽습니다. 한국에서 글로벌에 비빌만한 유일한 기업인데, 직원 대우도 글로벌 수준으로 갔으면 합니다."
## [4] "연봉이 많은 만큼 힘도 많이들고 야근이 많다. 힘든 만큼 돈도 많이 들어오니 힘든 만큼 들어오는 말이다."                                                                                                                                                                                                          
## [5] "부서바이부서지만 아직도 존재하는 군대 문화, 서류적인 보고에 너무 집착"

items %>% html_nodes(css = 'dl dd:nth-child(6) span') %>% html_text()
## [1] "빈번한 조직개편으로 인해 장기적인 과제를 수행할 수 없고 이에 따라 시간이 지날 수록 연구원들의 연구역량이 떨어짐. 안정된 조직운영을 바랍니다."                                                                                                                                                 
## [2] "직군간에 차이가 나면 뽑을때도 차별있게 뽑읍시다.. 대졸나와서 고졸한테 이래라저래라 소리들으면 스트레스받음"                                                                                                                                                                                   
## [3] "제가 있던 사업부는 상당히 경쟁사를 뒤쫓는 분위기였어서, 미리미리 앞서나가지 못하는 것이 좀 아쉬웠습니다. 제조업의 체질개선이 필요하다고 생각하고 또 이미 그렇게 하고 있ㅈ만, 뭔가 핵심적인 건 그대로인 것 같습니다. 들어보니 포기하고 다시 제조기반 역량을 핵심 역량으로 삼겠다던데 글쎄요..."
## [4] "최근에 사업하는 것이 전망이 잘보이지만 잘 보이는 만큼 경영도 잘 해주셨으면 좋겠습니다."                                                                                                                                                                                                       
## [5] "업무를 즉흥적으로 지시 하지말고 방향성을 가지고 지시했으면 좋겠음, 방향이 자주 바뀜"  

items %>% html_nodes(css = 'p.etc_box strong') %>% html_text()
## [1] "비슷" "성장" "성장" "성장" "비슷"

items %>% html_nodes(css = 'p.txt.recommend.etc_box') %>% html_text()
## [1] "이 기업을 추천하지 않습니다." "이 기업을 추천하지 않습니다." "이 기업을 추천 합니다!"      
## [4] "이 기업을 추천 합니다!"       "이 기업을 추천 합니다!" 


# CSS Selector로 텍스트만 수집하는 함수를 생성합니다.
getHtmlText <- function(x, css) {
  
  result <- x %>% 
    html_node(css = css) %>% 
    html_text()
  
  return(result)
}


# CSS Selector로 별점을 수집하는 함수를 생성합니다.
getHtmlRate <- function(x, css, name) {
  
  result <- x %>% 
    html_node(css = css) %>% 
    html_attr(name = name) %>% 
    str_remove_all(pattern = '(width:)|(%;)') %>% 
    as.numeric()
  
  return(result)
}


# 개별 기업리뷰를 수집하고 데이터 프레임으로 반환하는 함수를 생성합니다.
getData <- function(x) {
  
  # 기업리뷰를 포함하는 HTML 요소를 추출하여 items 객체에 할당합니다.
  items <- x %>% read_html() %>% html_nodes(css = 'section.content_ty4')
  
  # 웹 데이터를 수집하여 df 객체에 할당합니다. 
  df <- 
    data.frame(
      회사이름 = x %>% read_html() %>% html_node(css = 'h2.tit') %>% html_text(),
      회사코드 = items %>% html_attr(name = 'data-company_id'),
      리뷰코드 = items %>% html_attr(name = 'data-content_id'),
      직종구분 = getHtmlText(x = items, css = 'div.content_top_ty2 span:nth-child(2)'),
      재직상태 = getHtmlText(x = items, css = 'div.content_top_ty2 span:nth-child(4)'),
      근무지역 = getHtmlText(x = items, css = 'div.content_top_ty2 span:nth-child(6)'),
      등록일자 = getHtmlText(x = items, css = 'div.content_top_ty2 span.txt2'),
      별점평가 = getHtmlRate(x = items, css = 'div.star_score', name = 'style'),
      승진기회 = getHtmlRate(x = items, css = 'dl dd:nth-child(3) div div', name = 'style'),
      복지급여 = getHtmlRate(x = items, css = 'dl dd:nth-child(5) div div', name = 'style'),
      워라밸   = getHtmlRate(x = items, css = 'dl dd:nth-child(7) div div', name = 'style'),
      사내문화 = getHtmlRate(x = items, css = 'dl dd:nth-child(9) div div', name = 'style'),
      경영진   = getHtmlRate(x = items, css = 'dl dd:nth-child(11) div div', name = 'style'),
      기업장점 = getHtmlText(x = items, css = 'dl dd:nth-child(2) span'),
      기업단점 = getHtmlText(x = items, css = 'dl dd:nth-child(4) span'),
      바라는점 = getHtmlText(x = items, css = 'dl dd:nth-child(6) span'),
      성장예상 = getHtmlText(x = items, css = 'p.etc_box strong'),
      추천여부 = getHtmlText(x = items, css = 'p.txt.recommend.etc_box')
    )
  
  return(df)
}


# 총 페이지 수 계산하고 그 결과를 출력합니다. 
pages <- ceiling(x = reviewCnt / 5)
print(x = pages)
## [1] 1030

# 결과를 저장할 객체 생성
result <- getData(x = resp)

# result 객체를 출력합니다. 
print(x = result)

## 회사이름 회사코드 리뷰코드  직종구분 재직상태 근무지역     등록일자 별점평가 승진기회 복지급여 워라밸 사내문화 경영진
## 1     <NA>    30139  1759527  연구개발   현직원     서울 2020. 07. 21       80       60       80     80       80     60
## 2     <NA>    30139  1758711 생산/제조   현직원     경기 2020. 07. 20       60       80      100    100      100     40
## 3     <NA>    30139  1756417 IT/인터넷   전직원     경기 2020. 07. 19      100      100      100     40       60     80
## 4     <NA>    30139  1756052 생산/제조   현직원     경기 2020. 07. 18      100       80      100     80      100    100
## 5     <NA>    30139  1755739 생산/제조   현직원     경기 2020. 07. 18       60       80       80     60       40     40
## 기업장점
## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      위치가 서울, 워라벨 좋은편, 자율출퇴근제도, 식당밥 좋음, 높은 보수
## 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                돈. 자부심( 외부사람들에게)   자괴감( 내부 상대적박탈감)
## 3 역량을 쌓기 정말 좋습니다. 이 회사는 학사도 연구개발에 배치해주고 대학이나 학점도 별로 가리지 않습니다. 공평하게 뽑아서 역량향상의 기회를 제공하는 느낌입니다. 다만 워라밸은 찾기 힘듭니다. 물론 근무시간은 예전보다 많이 줄고 있지만, 성과 압박이나 업무량으로 인해 다들 얼굴이 어둡습니다. 이건 사업부 그리고 팀마다 다르긴 하겠죠. 역량을 쌓아서 떠나기 좋은 곳입니다. 그리고 복지나 연봉 괜찮습니다. 연봉이 높지만 사실 성과급이 큰 역할을 차지하고 계약은 크지 않습니다. 삼전보다 많이 주고 복지 좋은 곳도 많습니다. Skt나 기름집이라든가... 다만 사내 새마을금고에서 대출이 빵빵하게 나온다든가, 식당 퀄이 미쳤다든가 헬스장 시걸이 좋다든가 등은 다른 기업이 따라하기 힘든 점 같네요. 회사가 수원인 점이 안 좋다고 생각했으나 나중에 다시 보니 수원이 차라리 집 구하기도 좋았던 거 같아요. 짧게 다니고 이직했고 또 이직할 때 고민도 많았으나, 많은 걸 배웠고 이직한 곳에서도 삼전에서 배운 거 잘 써먹구 있습니다
## 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                연차와 월차를 마음대로 쓸 수가 있다. 그리고 복지와 혜택같은 게 많으며 나무랄 곳이 없습니다. 선배님들이 워낙 학력 상관없이 잘 대해줍니다.
## 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                경기도에 위치해서 접근성이 좋음, 기업의 네임 밸류는 최상
## 기업단점
## 1                                                                                                                                                                                                                                                     단기성과 위주의 연구조직으로 경력 커리어 관리가 쉽지 않음
## 2                                                                                                                                                                                                                                                내부적으로도 직군간 업무난도에대한 불만과 보여주기식정책이많음
## 3 워라밸, 특히 업무의 양이 일부 직원과 부서에 너무 편중되어있고 신입 인력의 배치가 적재적소에 되는 느낌이 아닙니다. 부족한 부서는 언제나 부족합니다. 그리고 네임밸류에 비해 복지와 계약연봉이 작은 점은 조금 아쉽습니다. 한국에서 글로벌에 비빌만한 유일한 기업인데, 직원 대우도 글로벌 수준으로 갔으면 합니다.
## 4                                                                                                                                                                                                           연봉이 많은 만큼 힘도 많이들고 야근이 많다. 힘든 만큼 돈도 많이 들어오니 힘든 만큼 들어오는 말이다.
## 5                                                                                                                                                                                                                                         부서바이부서지만 아직도 존재하는 군대 문화, 서류적인 보고에 너무 집착
## 바라는점
## 1                                                                                                                                                  빈번한 조직개편으로 인해 장기적인 과제를 수행할 수 없고 이에 따라 시간이 지날 수록 연구원들의 연구역량이 떨어짐. 안정된 조직운영을 바랍니다.
## 2                                                                                                                                                                                    직군간에 차이가 나면 뽑을때도 차별있게 뽑읍시다.. 대졸나와서 고졸한테 이래라저래라 소리들으면 스트레스받음
## 3 제가 있던 사업부는 상당히 경쟁사를 뒤쫓는 분위기였어서, 미리미리 앞서나가지 못하는 것이 좀 아쉬웠습니다. 제조업의 체질개선이 필요하다고 생각하고 또 이미 그렇게 하고 있ㅈ만, 뭔가 핵심적인 건 그대로인 것 같습니다. 들어보니 포기하고 다시 제조기반 역량을 핵심 역량으로 삼겠다던데 글쎄요...
## 4                                                                                                                                                                                                        최근에 사업하는 것이 전망이 잘보이지만 잘 보이는 만큼 경영도 잘 해주셨으면 좋겠습니다.
## 5                                                                                                                                                                                                           업무를 즉흥적으로 지시 하지말고 방향성을 가지고 지시했으면 좋겠음, 방향이 자주 바뀜
## 성장예상                     추천여부
## 1     비슷 이 기업을 추천하지 않습니다.
## 2     성장 이 기업을 추천하지 않습니다.
## 3     성장       이 기업을 추천 합니다!
## 4     성장       이 기업을 추천 합니다!
## 5     비슷       이 기업을 추천 합니다!


# 반복문을 실행합니다. 
for (page in 2:pages) {
  
  # 작업 시작시각을 저장합니다.
  startTime <- Sys.time()
  
  # 현재 진행사항을 출력합니다.
  cat('[', page, '/', pages, '] 현재 진행 중! ')
  
  # 웹 페이지 URI를 조립합니다.
  cURI <- str_c(URI, '?page=', page)
  
  # HTTP 요청을 합니다.
  resp <- GET(url = cURI, config = list(cookies = myCookies))
  
  # 해당 페이지의 기업리뷰를 추출하여 df 객체에 할당합니다.
  df <- getData(x = resp)
  
  # result 객체에 df 객체를 추가합니다.
  result <- rbind(result, df)
  
  # 작업 종료시각를 저장합니다.
  endTime <- Sys.time()
  
  # 작업에 소요된 시간을 출력합니다.
  (endTime - startTime) %>% print()
  
  # 불필요한 객체를 삭제합니다. 
  rm(resp, df)
  
}


# 리뷰코드로 중복여부를 확인합니다.
duplicated(x = result$리뷰코드) %>% sum()
## [1] 0

# 최종 데이터를 RDS로 저장합니다.
fileNm <- str_c('../documents/Company_Review_Data_', compNm, '.RDS')
saveRDS(object = result, file = fileNm)

write.csv(Company_Review_Data_삼성전자, file = "../documents/Review.csv")
