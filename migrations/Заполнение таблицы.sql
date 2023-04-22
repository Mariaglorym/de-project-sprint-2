--Заполнение данными shipping_country_rates
INSERT INTO
    public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT
    shipping_country,
    shipping_country_base_rate
from
    public.shipping s
group by
    shipping_country,
    shipping_country_base_rate 

--Заполнение данными shipping_agreement
INSERT INTO
    public.shipping_agreement (
        agreement_id,
        agreement_number,
        agreement_rate,
        agreement_commission
    )
select
    distinct agreement_description [1] :: BIGINT,
    agreement_description [2],
    agreement_description [3] :: NUMERIC(14, 2),
    agreement_description [4] :: NUMERIC(14, 2)
from
    (
        select
            regexp_split_to_array(vendor_agreement_description, ':+') as agreement_description
        from
            public.shipping s
    ) s2 

--Заполнение данными shipping_transfer
INSERT INTO
    public.shipping_transfer (
        transfer_type,
        transfer_model,
        shipping_transfer_rate
    )
select
    distinct transfer_description [1] :: text,
    transfer_description [2] :: text,
    shipping_transfer_rate :: NUMERIC(14, 2)
from
    (
        select
            regexp_split_to_array(shipping_transfer_description, ':+') as transfer_description,
            shipping_transfer_rate
        from
            public.shipping s
    ) s2 

--Заполнение данными shipping_info
INSERT INTO
    public.shipping_info (
        shipping_id,
        vendor_id,
        payment_amount,
        shipping_plan_datetime,
        shipping_transfer_id,
        shipping_agremeent_id,
        shipping_country_rate_id
    )
select
    shipping_id,
    vendor_id,
    payment_amount,
    shipping_plan_datetime,
    st.id as shipping_transfer_id,
    sa.agreement_id as shipping_agremeent_id,
    scr.id as shipping_country_rate_id
from
    (
        select
            shipping_id,
            vendor_id,
            payment_amount,
            shipping_plan_datetime,
            shipping_country,
            regexp_split_to_array(vendor_agreement_description, ':+') as agreement_description,
            regexp_split_to_array(shipping_transfer_description, ':+') as transfer_description
        from
            public.shipping s
    ) s2
    join shipping_transfer st on st.transfer_type = s2.transfer_description [1] :: text
    and st.transfer_model = transfer_description [2] :: text
    join shipping_agreement sa on sa.agreement_id = s2.agreement_description [1] :: BIGINT
    join shipping_country_rates scr on scr.shipping_country = s2.shipping_country
group by
    shipping_id,
    vendor_id,
    payment_amount,
    shipping_plan_datetime,
    st.id,
    sa.agreement_id,
    scr.id 

--Заполнение данными shipping_status
INSERT INTO
    public.shipping_status (
        shipping_id,
        status,
        state,
        shipping_start_fact_datetime,
        shipping_end_fact_datetime
    )
select
    distinct s.shipping_id,
    last_value(s.status) OVER(
        PARTITION BY s.shipping_id
        ORDER BY
            s.state_datetime RANGE BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS last_status,
    last_value(s.state) OVER(
        PARTITION BY s.shipping_id
        ORDER BY
            s.state_datetime RANGE BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS last_state,
    s2.shipping_start_fact_datetime,
    s2.shipping_end_fact_datetime
from
    shipping s
    join (
        select
            shipping_id,
            max(
                case
                    when state = 'booked' then state_datetime
                end
            ) as shipping_start_fact_datetime,
            max(
                case
                    when state = 'recieved' then state_datetime
                end
            ) as shipping_end_fact_datetime
        from
            shipping s
        group by
            shipping_id
    ) s2 on s2.shipping_id = s.shipping_id