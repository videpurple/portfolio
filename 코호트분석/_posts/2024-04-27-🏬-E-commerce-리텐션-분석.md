# 🏬 E-commerce 리텐션 분석
title: 🏬 E-commerce 리텐션 분석
---

작성자: 이보라
태그: 리텐션분석, 프로젝트
Skills: Google Sheets, Mysql
기간: 2023년 7월 15일 → 2023년 7월 21일
기여도: 100%

> 목차
> 

# 1️⃣ 분석 목적

## 1. 분석 가정 및 목적

H사는 선물하기 좋은 제품부터 실생활에 유용한 가정 용품까지 다양한 제품을 판매하는 영국의 온라인 편집숍입니다. 2018년 12월 사업을 시작하여 현재 1년이 되었습니다. 그동안 수집한 데이터를 분석하여 고객들이 지속적으로 서비스를 잘 이용하고 있는지 확인하고, 개선할 점이 있다면 방안을 모색하고자 합니다.

## 2. 분석 방법

### 리텐션 분석

- 리텐션은 사용자가 우리 서비스의 핵심 가치를 얼마나 꾸준히 경험하는지 확인하는 지표입니다. 이 지표를 분석하기 위해서 두 가지 과정을 거치게 됩니다.
    - **코호트 분석** : 공통적인 특성에 따라 여러 집단으로 분류한 사용자 그룹을 코호트라고 하고 리텐션 분석에서는 주로 날짜를 기준으로 분류하여 살펴봅니다.
    - **리텐션** **차트** 작성 : 앞서 실행한 코호트 분석에 따라 리텐션이 어떻게 움직이는지 시각화하는 작업입니다.

# 2️⃣ 분석 결과

## 1. 구매 주기

<aside>
🔖 우리 서비스의 구매 주기 중앙값은 **57일** 입니다.

</aside>

✔️ 분석 대상 :  최초 구매일 이후 1일이 지난 시점부터 구매 기록이 있는 고객 (전체 고객의 약 66%)

✔️ 구매 주기 = (마지막 구매일 - 첫 구매일) / (구매 횟수 - 1)

![구매 주기에 따른 고객 수.png](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/%25EA%25B5%25AC%25EB%25A7%25A4_%25EC%25A3%25BC%25EA%25B8%25B0%25EC%2597%2590_%25EB%2594%25B0%25EB%25A5%25B8_%25EA%25B3%25A0%25EA%25B0%259D_%25EC%2588%2598.png)

![구매 주기에 따른 고객 비율.png](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/%25EA%25B5%25AC%25EB%25A7%25A4_%25EC%25A3%25BC%25EA%25B8%25B0%25EC%2597%2590_%25EB%2594%25B0%25EB%25A5%25B8_%25EA%25B3%25A0%25EA%25B0%259D_%25EB%25B9%2584%25EC%259C%25A8.png)

- 분석 대상 고객 중 절반 이상의 구매 주기가 1일 ~ 60일 사이인 것을 알 수 있습니다.
- 평균 구매 주기는 78.4일, 구매 주기 중앙값은 57일 입니다.
- 다양한 용도의 제품을 판매하므로 구매 주기가 매우 다양하게 분포합니다. 양극 값의 영향을 적게 받기 위해 리텐션 범위 기준으로 구매 주기 **중앙값을 채택**하게 되었습니다.
- SQL 쿼리
    
    ```sql
    -- 구매 주기별 고객 수
    WITH cycle AS (
    	SELECT ROUND(DATEDIFF(last_order_date, first_order_date) / (cnt_orders - 1), 0) AS purchase_cycle 
    		 , CustomerId
    	FROM customer_stats
    	WHERE cnt_orders >= 2
    	GROUP BY purchase_cycle, CustomerId HAVING purchase_cycle > 0
    	ORDER BY purchase_cycle
    )
    SELECT COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 1 AND 60 THEN CustomerId END) AS '1~60'
    	   , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 61 AND 120 THEN CustomerId END) AS '61~120'
         , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 121 AND 180 THEN CustomerId END) AS '121~180'
         , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 181 AND 240 THEN CustomerId END) AS '181~240'
         , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 241 AND 300 THEN CustomerId END) AS '241~300'
         , COUNT(DISTINCT CASE WHEN purchase_cycle BETWEEN 301 AND 360 THEN CustomerId END) AS '301~360'
         , COUNT(DISTINCT CASE WHEN purchase_cycle > 360 THEN CustomerId END) AS '360~'
    FROM cycle;
    
    -- 구매주기 평균 및 중앙값은 구글 시트를 이용하였습니다.
    ```
    

## 2. 리텐션 분석

> 서비스의 이용 주기가 긴 편이므로 기간을 묶어서 분석하는 **범위 리텐션**을 이용하였습니다. 
기간을 묶는 기준은 구매 주기 중앙값(57)일을 참고하여 **2개월(60일)**로 묶었습니다. 
각 달의 Month 0은 해당 월에 첫 구매한 고객 수를 나타냅니다.
> 

<aside>
🔖 2018년 12월에 비해 2019년 1월에 첫 구매한 고객 수가 급격하게 감소하였습니다. 2019년 11월 첫 구매 고객 수는 2018년 12월과 비교하여 **약 72% 감소**하였습니다.
2019년 8월에 가장 낮은 첫 구매 고객 수(173명)를 달성했지만 바로 다음 달에 첫 구매 고객 수가 **8월에 비해 63% 상승**했습니다.

</aside>

![Untitled](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/Untitled.png)

- 2019년 8월에 비해 9월의 첫 구매 고객 수가 높아진 이유는 9월이 신학기 준비 시즌으로 이 시즌에 주로 쇼핑이 이루어지는 시기이기 때문입니다.
- 9월 이후 첫 구매 고객 수가 어느 정도 유지 되는 것은 10월 핼러윈, 11월 블랙 프라이데이와 같은 큰 쇼핑 이벤트가 존재합니다. 더불어 10월부터 길거리에서 크리스마스 장식을 볼 수 있을 정도로 크리스마스 준비를 미리 하는 문화도 영향을 준 것으로 보입니다. 실제로 10월, 11월 구매 목록을 보면 크리스마스 관련 용품의 구매가 이루어지고 있음을 알 수 있습니다.
    
    
    - 10월 첫 구매자들 구매 제품 목록
    (총 구매 수 상위 10개)
        
        
        | 제품명 | 총 구매 수  |
        | --- | --- |
        | Popcorn Holder | 945 |
        | Wooden Heart Christmas Scandinavian | 805 |
        | World War 2 Gliders Asstd Designs | 738 |
        | Assorted Colours Silk Fan | 704 |
        | Paper Chain Kit 50'S Christmas | 576 |
        | Assorted Colour Bird Ornament | 567 |
        | Vintage Snap Cards | 530 |
        | Christmas Hanging Star With Bell | 473 |
        | Hanging Heart With Bell | 442 |
        | 60 Cake Cases Vintage Christmas | 435 |
    
    - 11월 첫 구매자들 구매 제품 목록
    (총 구매 수 상위 10개)
        
        
        | 제품명 | 총 구매 수  |
        | --- | --- |
        | Asstd Design 3d
          Paper Stickers | 12544 |
        | Popcorn Holder | 3373 |
        | Rabbit Night Light | 1645 |
        | Paper Chain Kit 50'S Christmas | 1538 |
        | Jumbo Bag Red Retrospot | 1170 |
        | Jumbo Bag 50'S Christmas | 1103 |
        | Traditional Pick Up Sticks Game | 978 |
        | Wooden Star Christmas Scandinavian | 934 |
        | Doughnut Lip Gloss | 886 |
        | Traditional Naughts & Crosses | 860 |
    - 구매 제품 목록 SQL 쿼리
        
        ```sql
        -- 10월 첫구매자 구매 제품 확인
        WITH records_join AS (
        SELECT r.CustomerId
        		 , r.OrderDate
             , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
             , r.ProductName
             , r.Price
             , r.Quantity
             , r.Country
        FROM records r
        	 INNER JOIN customer_stats c ON r.CustomerId = c.CustomerId
        )
        SELECT DISTINCT ProductName
        		 , SUM(Quantity) cnt_product
        FROM records_join
        WHERE first_order_month = '2019-10-01'
        AND OrderDate BETWEEN '2019-10-01' AND '2019-10-31'
        GROUP BY ProductName
        ORDER BY cnt_product DESC;
        
        -- 11월 첫구매자 구매 제품 확인
        WITH records_join AS (
        SELECT r.CustomerId
        		 , r.OrderDate
             , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
             , r.ProductName
             , r.Price
             , r.Quantity
             , r.Country
        FROM records r
        	 INNER JOIN customer_stats c ON r.CustomerId = c.CustomerId
        )
        SELECT DISTINCT ProductName
        		 , SUM(Quantity) cnt_product
        FROM records_join
        WHERE first_order_month = '2019-11-01'
        AND OrderDate BETWEEN '2019-11-01' AND '2019-11-30'
        GROUP BY ProductName
        ORDER BY cnt_product DESC;
        ```
        
- 2019 영국 주요 쇼핑 시즌 - [참고](https://m.post.naver.com/viewer/postView.naver?volumeNo=17526030&memberNo=38390862)
    
    
    | 기념일 | 날짜 | 설명 |
    | --- | --- | --- |
    | 새해
    (New Year) | 1월 1일 | 새해가 되면 한 해의 계획을 세우고, 가족과 친구들에게 연하장과 선물을 보내며 인사를 합니다.
    인기 상품 : 행운과 관련된 아이템, 개인 건강 용품, 인사 카드 등 |
    | 발렌타인 데이
    (Valentine's Day) | 2월 14일 | 전통적으로 연인들이 초콜릿을 주고 받는 날이었지만 이제는 가족, 친구, 반려동물과 같이 사랑하는 이들을 위해 선물을 준비합니다.
    인기 상품 : 초콜릿, 카드, 주얼리 등 |
    | 성 패트릭 데이
    (ST. Patricks 's Day) | 3월 17일 | 아일랜드의 수호성인인 성 파트리치오를 기념하는 날로 녹색 의상을 입고, 녹색 색상의 음식을 먹습니다.
    인기 상품 : 티셔츠, 모자, 파티 용품, 아일랜드 상징물 등 |
    | 어머니의 날
    (Mother's Day) | 영국의 사순절 중 넷째 일요일
    (2019년에는 3월 31일) | 어머니 또는 어머니처럼 모시는 어르신께 카드나 선물을 보내는 날입니다.
    인기 상품 : 주얼리, 꽃, 간식 등  |
    | 부활절 연휴
    (Easter Holiday) | 4월 19일 ~ 22일 | 영국에서 크리스마스 다음으로 가장 큰 명절로 예수가 십자가에 못 박힌 날이 Good Friday부터 Easter Monday까지 연휴 기간입니다.
    인기 상품 : 플라스틱 달걀, 작은 선물, 장식품, 종교 상품 등 |
    | 아버지의 날
    (Father's Day) | 6월의 세번째 일요일
    (2019년에는 6월 16일) | 아버지 또는 아버지처럼 모시는 어르신께 카드나 선물을 보내는 날입니다.
    인기 상품 : 넥타이, 도서, 양말, 향수, 스포츠 용품 등 |
    | 새 학기
    (Back to School) | 9월 | 학생들이 신학기를 준비하는 시즌입니다.
    인기 상품 : 책, 문구류, 필기구 등 |
    | 핼러윈
    (Halloween) | 10월 31일 | 어린이들에게 사탕을 주고 변장 파티에 참석하거나 유럽의 집을 방문합니다.
    인기 상품 : 핼러윈 의상, 메이크업 및 액세서리 등 |
    | 블랙 프라이데이
    (Black Friday) | 11월 29일 | 크리스마스 쇼핑 시즌의 시작을 알리는 날로 파격적인 할인 헤택을 제공합니다.
    인기 상품 : 주로 고가 제품 |
    | 사이버 먼데이
    (Cyber Monday) | 12월 2일 | 추수감사절 다음 주의 첫 번째 월요일로, 온라인 쇼핑몰이 할인 프로모션을 진행합니다.
    인기 상품 : 주로 고가 제품 |
    | 크리스마스
    (Christmas) | 12월 25일 | 영국에서 가장 중요한 날입니다. 가족, 친지와 함께 집을 장식하고 선물을 교환하며 함께 식사를 합니다.
    인기 상품 : 선물과 관련된 제품, 크리스마스 장식, 인사 카드, 양초, 달력, 조명 등 |
    | 박싱데이
    (Boxing Day) | 12월 26일 | 국경일이자 영국의 연례 할인 행사가 시작되는 날입니다. 크리스마스부터 신년 전야까지 진행됩니다.
    인기 상품 : 할인 표시된 모든 상품, 겨울 의류, 전자 제품, 신발, 향수, 시계, 귀금속 등 |

<aside>
🔖 Month 2 평균 유지율이 33.8%로, 업종 대부분의 8주 후 평균 유지율이 20% 미만[¹⁾](https://www.notion.so/E-commerce-96580757189845629c7c224f6c7c6733?pvs=21)인 것에 반해 **높은 유지율**을 보이고 있습니다.
Month 2에서 **유지율이 가장 낮고**, 중간에 잠시 하락 혹은 유지하는 구간이 존재하지만 대체적으로 유지율이 증가하는 추세를 볼 수 있습니다.
→ Month2 유지율을 높일 수 있는 방안을 찾아야 합니다.

</aside>

![Untitled](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/Untitled%201.png)

![기간에 따른 유지율 변화.png](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/%25EA%25B8%25B0%25EA%25B0%2584%25EC%2597%2590_%25EB%2594%25B0%25EB%25A5%25B8_%25EC%259C%25A0%25EC%25A7%2580%25EC%259C%25A8_%25EB%25B3%2580%25ED%2599%2594.png)

<aside>
🔖 각 코호트에서 첫 구매 이후 8월에 도달했을 때 유지율이 낮아지는 구간이 존재합니다. 8월에 세일 이벤트나 기념 이벤트가 존재하지 않아 감소한 것으로 보입니다.

</aside>

![Untitled](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/Untitled%202.png)

- SQL 쿼리
    
    ```sql
    WITH records_preprocessed AS (
    SELECT r.CustomerId
    	 , DATE_FORMAT(r.OrderDate, '%Y-%m-01') order_month
         , DATE_FORMAT(c.first_order_date, '%Y-%m-01') first_order_month
    FROM records r
    	 INNER JOIN customer_stats c ON r.CustomerId = c.CustomerId
    )
    
    SELECT first_order_month
    		 , COUNT(DISTINCT CustomerId) 'Month 0'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 1 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 2 MONTH)
    			 THEN CustomerId END) 'Month 2'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 3 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 4 MONTH)
    			 THEN CustomerId END) 'Month 4'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 5 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 6 MONTH)
    			 THEN CustomerId END) 'Month 6'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 7 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 8 MONTH)
    			 THEN CustomerId END) 'Month 8'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 9 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 10 MONTH)
    			 THEN CustomerId END) 'Month 10'
         , COUNT(DISTINCT CASE WHEN order_month = DATE_ADD(first_order_month, INTERVAL 11 MONTH) OR order_month = DATE_ADD(first_order_month, INTERVAL 12 MONTH)
    			 THEN CustomerId END) 'Month 12'
    FROM records_preprocessed
    GROUP BY first_order_month
    ORDER BY first_order_month;
    ```
    

# 3️⃣ 제안

개선 사항 1. 점점 감소하는 첫 구매 고객 수를 늘릴 필요가 있습니다.

![월별 첫 구매 고객 수.png](%F0%9F%8F%AC%20E-commerce%20%E1%84%85%E1%85%B5%E1%84%90%E1%85%A6%E1%86%AB%E1%84%89%E1%85%A7%E1%86%AB%20%E1%84%87%E1%85%AE%E1%86%AB%E1%84%89%E1%85%A5%E1%86%A8%2096580757189845629c7c224f6c7c6733/%25EC%259B%2594%25EB%25B3%2584_%25EC%25B2%25AB_%25EA%25B5%25AC%25EB%25A7%25A4_%25EA%25B3%25A0%25EA%25B0%259D_%25EC%2588%2598.png)

`**Action Plan1 - 기존 고객을 대상으로 친구 추천 이벤트 추가**` 

- 기존 고객을 대상으로 새로운 친구 추천 이벤트를 추가하여 추천한 친구가 물건을 구매할 경우 추천한 고객과 추천 받은 고객 모두 포인트 적립 혹은 배송비 무료 중 한 가지를 선택할 수 있도록 합니다. 이를 통해 신규 가입으로 그치는 것이 아니라 첫 구매를 유도함으로써 서비스를 지속적으로 이용할 잠재적 고객을 늘리는 것이 중요하다 생각합니다.

**`Action Plan2 - 첫 구매 혜택 프로모션 진행`**

- 우리 서비스를 방문하여 첫 구매하는 고객을 대상으로 선물 포장 서비스, 첫 구매 할인 이벤트를 진행하고 이를 홍보하여 첫 구매 고객이 유입될 수 있도록 합니다.

개선 사항 2. 첫 구매 이후 2개월 이내의 유지율을 높여야 합니다.

**`Action Plan - 첫 구매 이후 2개월이 경과하기 전 푸시 알림을 통한 구매 유도`**

- 첫 구매 이후 구매 기록이 없는 고객을 대상으로 2개월 경과 이전 푸시 알림을 통해 다시 우리 서비스에 방문할 수 있도록 유도하고, 푸시 알림에 평소 검색했던 제품을 추천하거나 깜짝 할인 쿠폰을 제공하여 구매를 유도합니다.

개선 사항 3. 8월에 구매 고객 수를 늘릴 수 있는 방안을 모색해야 합니다.

**`Action Plan - 여름 방학 기념 세일`**

- 학교마다 다르기는 하지만 8월은 영국의 여름 방학 기간이기도 합니다. 여름 관련 제품, 휴가 관련 제품, 방학 기간에 가족들과 즐길 수 있는 체험 활동 관련 제품(베이킹, 공예 등)의 할인을 통해 8월에 구매자 수를 늘리고자 합니다.

개선 사항 4. 기간이 더 지날수록 유지율의 감소 경사가 낮아지도록 관리해야 합니다.

**`Action Plan - 캘린더 연동을 통한 기념일, 생일 알림 및 선물 추천`**

- 초반 유지율을 높이는 것과 더불어 앞으로 서비스의 유지율이 최대한 완만하게 유지될 수 있도록 꾸준히 관리해야 합니다. 캘린더 연동에 동의한 고객에 한해서 캘린더에 저장되어 있는 가족, 친구의 생일 및 기념일에 맞추어 알림 및 선물을 추천합니다. 캘린더 연동을 하지 않더라도 공통적으로 챙기는 기념일(새해, 어머니의 날, 아버지의 날 등등)에 알림을 통해 선물을 추천하여 방문 및 구매를 유도합니다.

# 4️⃣ 데이터 설명

데이터 출처 : Kaggle **[E-commerce Business Transaction](https://www.kaggle.com/datasets/gabrielramos87/an-online-shop-business)**

데이터 수집 기간 : 2018년 12월 1일 ~ 2019년 12월 9일

- 1. records
    
    
    | 컬럼명 | 내용 |
    | --- | --- |
    | OrderId | 주문 번호 |
    | OrderDate  | 주문 날짜 |
    | ProductNo | 제품 번호 |
    | ProductName | 제품명 |
    | Price | 제품 한 개의 가격 (파운드) |
    | Quantity | 구매 수량 |
    | CustomerId | 고객의 고유 번호 |
    | Country | 고객이 거주하는 국가 |
- 2. customer_stats
    
    → 리텐션 분석을 위해 records를 요약한 테이블
    
    | 컬럼명 | 내용 |
    | --- | --- |
    | CustomerID | 고객의 고유 번호 |
    | first_order_date | 첫 주문일 |
    | last_order_date | 마지막 주문일 |
    | cnt_orders | 주문 횟수 |
    | sum_sales | 총 구매금액 합계(파운드) |
    - SQL 쿼리
        
        ```sql
        SELECT DISTINCT CustomerId
        	   , MIN(Date) first_order_date
        	   , MAX(Date) last_order_date
             , COUNT(DISTINCT OrderId) cnt_orders
             , ROUND(SUM(Price * Quantity), 2) sum_sales
        FROM records
        GROUP BY CustomerId
        ```
        

# 5️⃣ 회고

- Liked(좋았던 점) - 처음 수업으로 배웠을 때에는 리텐션 차트 분석에 대해 헷갈렸는데 프로젝트를 진행하면서 직접 해보니 헷갈렸던 부분이 해소되었고, 리텐션 분석에 대해 더 깊이 공부해볼 수 있는 시간이 되었습니다.
- Lacked(아쉬웠던 점) - 제품을 분류하는 카테고리가 존재하지 않아 카테고리별 구매 주기를 구할 수 없는 점이 아쉬웠습니다.
- Learned(배운 점) - 리텐션 분석에 대한 이해 뿐 아니라 프로젝트를 진행할 때 목적을 명확히 설정하는 것이 중요하다는 것을 다시금 느낄 수 있었습니다.
- Longed for(앞으로 바라는 점) - 범위 리텐션 뿐만 아니라 클래식 리텐션, 롤링 리텐션이 어떻게 분석에 적용이 되고, 실제로 어떤 리텐션을 적용하는 것이 좋은지 판단할 수 있는 역량을 기르도록 노력하겠습니다.

---

¹⁾출처 : **Mixpanel(이벤트 분석 서비스 회사)** [User retention rate for mobile apps and websites](https://mixpanel.com/blog/whats-a-good-retention-rate/)

> 본 내용은 데이터리안 'SQL 데이터 분석 캠프 실전반' 을 수강하며 작성한 내용입니다.
>
