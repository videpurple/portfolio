-- 각 단계로 이동한 이용자 수, 전환율 구하기
WITH create_user AS (
  SELECT user_id
       , occurred_at AS create_at
  FROM tutorial.yammer_events
  WHERE event_name = 'create_user'
), email AS (
  SELECT user_id
       , occurred_at AS email_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_email'
), info AS (
  SELECT user_id
       , occurred_at AS info_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_info'
), complete AS (
  SELECT user_id
       , occurred_at AS complete_at
  FROM tutorial.yammer_events
  WHERE event_name = 'complete_signup'
)

SELECT COUNT(DISTINCT create_user.user_id) create_user
     , COUNT(DISTINCT email.user_id) AS enter_email
     , COUNT(DISTINCT info.user_id) AS enter_info
     , COUNT(DISTINCT complete.user_id) AS complete_signup
     , COUNT(DISTINCT email.user_id)::float / COUNT(DISTINCT create_user.user_id) AS create_email_rate
     , COUNT(DISTINCT info.user_id)::float  / COUNT(DISTINCT email.user_id) AS email_info_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT info.user_id) AS info_complete_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT create_user.user_id) AS create_complete_rate
FROM create_user 
     LEFT JOIN email ON create_user.user_id = email.user_id
                     AND create_at <= email_at
     LEFT JOIN info ON email.user_id = info.user_id 
                    AND email_at <= info_at
     LEFT JOIN complete ON info.user_id = complete.user_id
                        AND info_at <= complete_at;


-- 이용 기기 종류별 회원 가입 전환율
WITH create_user AS (
  SELECT user_id
       , device
       , occurred_at AS create_at
  FROM tutorial.yammer_events
  WHERE event_name = 'create_user'
), email AS (
  SELECT user_id
       , occurred_at AS email_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_email'
), info AS (
  SELECT user_id
       , occurred_at AS info_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_info'
), complete AS (
  SELECT user_id
       , occurred_at AS complete_at
  FROM tutorial.yammer_events
  WHERE event_name = 'complete_signup'
)

SELECT CASE 
            WHEN create_user.device IN ('ipad air', 'ipad mini', 'kindle fire', 'samsumg galaxy tablet') THEN 'tablet'
            WHEN create_user.device IN ('iphone 5', 'nexus 5', 'iphone 5s', 'iphone 4s', 'nexus 7', 'nexus 10', 'nokia lumia 635', 'samsung galaxy s4', 'htc one', 'samsung galaxy note', 'amazon fire phone') THEN 'phone'
            WHEN create_user.device IN ('dell inspiron desktop', 'hp pavilion desktop', 'acer aspire desktop', 'mac mini') THEN 'pc'
       ELSE 'notebook' END AS device_category
     , COUNT(DISTINCT create_user.user_id) create_user
     , COUNT(DISTINCT email.user_id) AS enter_email
     , COUNT(DISTINCT info.user_id) AS enter_info
     , COUNT(DISTINCT complete.user_id) AS complete_signup
     , COUNT(DISTINCT email.user_id)::float / COUNT(DISTINCT create_user.user_id) AS create_email_rate
     , COUNT(DISTINCT info.user_id)::float  / COUNT(DISTINCT email.user_id) AS email_info_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT info.user_id) AS info_complete_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT create_user.user_id) AS create_complete_rate
FROM create_user 
     LEFT JOIN email ON create_user.user_id = email.user_id
                     AND create_at <= email_at
     LEFT JOIN info ON email.user_id = info.user_id 
                    AND email_at <= info_at
     LEFT JOIN complete ON info.user_id = complete.user_id
                        AND info_at <= complete_at
GROUP BY device_category
ORDER BY create_user DESC;


-- 국가별 회원 가입 전환율
WITH create_user AS (
  SELECT user_id
       , location
       , occurred_at AS create_at
  FROM tutorial.yammer_events
  WHERE event_name = 'create_user'
), email AS (
  SELECT user_id
       , occurred_at AS email_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_email'
), info AS (
  SELECT user_id
       , occurred_at AS info_at
  FROM tutorial.yammer_events
  WHERE event_name = 'enter_info'
), complete AS (
  SELECT user_id
       , occurred_at AS complete_at
  FROM tutorial.yammer_events
  WHERE event_name = 'complete_signup'
)

SELECT create_user.location
     , COUNT(DISTINCT create_user.user_id) create_user
     , COUNT(DISTINCT email.user_id) AS enter_email
     , COUNT(DISTINCT info.user_id) AS enter_info
     , COUNT(DISTINCT complete.user_id) AS complete_signup
     , COUNT(DISTINCT email.user_id)::float / COUNT(DISTINCT create_user.user_id) AS create_email_rate
     , COUNT(DISTINCT info.user_id)::float  / COUNT(DISTINCT email.user_id) AS email_info_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT info.user_id) AS info_complete_rate
     , COUNT(DISTINCT complete.user_id)::float  / COUNT(DISTINCT create_user.user_id) AS create_complete_rate
FROM create_user 
     LEFT JOIN email ON create_user.user_id = email.user_id
                     AND create_at <= email_at
     LEFT JOIN info ON email.user_id = info.user_id 
                    AND email_at <= info_at
     LEFT JOIN complete ON info.user_id = complete.user_id
                        AND info_at <= complete_at
GROUP BY create_user.location
ORDER BY create_user DESC;


-- 회원 가입 후 로그인 시 이용한 기기 비율
WITH signup AS (
  SELECT user_id
       , occurred_at AS signup_at
  FROM tutorial.yammer_events
  WHERE event_name = 'complete_signup'
), login AS (
  SELECT user_id
       , device
       , occurred_at AS login_at
  FROM tutorial.yammer_events
  WHERE event_name = 'login'
)

SELECT CASE 
            WHEN login.device IN ('ipad air', 'ipad mini', 'kindle fire', 'samsumg galaxy tablet') THEN 'tablet'
            WHEN login.device IN ('iphone 5', 'nexus 5', 'iphone 5s', 'iphone 4s', 'nexus 7', 'nexus 10', 'nokia lumia 635', 'samsung galaxy s4', 'htc one', 'samsung galaxy note', 'amazon fire phone') THEN 'phone'
            WHEN login.device IN ('dell inspiron desktop', 'hp pavilion desktop', 'acer aspire desktop', 'mac mini') THEN 'pc'
       ELSE 'notebook' END AS device_category
     , COUNT(DISTINCT login.user_id) login_user
FROM login 
     INNER JOIN signup ON login.user_id = signup.user_id
                     AND signup_at <= login_at
GROUP BY device_category
ORDER BY login_user DESC;
