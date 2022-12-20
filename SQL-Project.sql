CREATE TABLE cust_trn (
    cust_no     INT,
    cust_name   VARCHAR2(500),
    opening_bal VARCHAR2(500),
    user_status VARCHAR2(500),
    auth_status VARCHAR2(500),
    dt_on       DATE DEFAULT sysdate
)

CREATE OR REPLACE PROCEDURE fib_cust_trn AS
    cust_no INT;
BEGIN
    FOR i IN (
        SELECT DISTINCT
            a.customer_no,
            a.customer_name,
            c.user_status,
            c.auth_status,
            b.acy_opening_bal,
            b.maker_dt_stamp
        FROM
            (
                SELECT
                    customer_no,
                    customer_name
                FROM
                    sgdynamic12.sytb_cust_single_info
            ) a
            LEFT JOIN (
                SELECT
                    cust_no,
                    acy_opening_bal,
                    maker_dt_stamp
                FROM
                    fcc12.sttm_cust_account
            ) b ON b.cust_no = a.customer_no
            LEFT JOIN (
                SELECT
                    user_status,
                    ext_fc_cust_id,
                    auth_status
                FROM
                    sgs12.cms_ib_user
            ) c ON a.customer_no = c.ext_fc_cust_id
        WHERE
                user_status = 'E'
            AND c.auth_status = 'A'
    ) LOOP
        BEGIN
            INSERT INTO cust_trn (
                cust_no,
                cust_name,
                opening_bal,
                user_status,
                auth_status,
                dt_on
            ) VALUES (
                i.customer_no,
                i.customer_name,
                i.acy_opening_bal,
                i.user_status,
                i.auth_status,
                i.maker_dt_stamp
            );

        END;
    END LOOP;

    COMMIT;
END;