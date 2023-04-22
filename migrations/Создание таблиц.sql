--Создание таблицы shipping_country_rates
CREATE TABLE public.shipping_country_rates(
   id SERIAL,
   shipping_country text,
   shipping_country_base_rate NUMERIC(14, 3),
   PRIMARY KEY (id)
);

CREATE INDEX shipping_country_rates_id_index ON public.shipping_country_rates(id);

--Создание таблицы shipping_agreement
CREATE TABLE public.shipping_agreement(
   agreement_id BIGINT,
   agreement_number text,
   agreement_rate NUMERIC(14, 2),
   agreement_commission NUMERIC(14, 2),
   PRIMARY KEY (agreement_id)
);

CREATE INDEX shipping_country_rates_agreement_id_index ON public.shipping_agreement(agreement_id);

--Создание таблицы shipping_transfer
CREATE TABLE public.shipping_transfer(
   id serial,
   transfer_type text,
   transfer_model text,
   shipping_transfer_rate NUMERIC(14, 2),
   PRIMARY KEY (id)
);

CREATE INDEX shipping_transfer_id_index ON public.shipping_transfer(id);

--Создание таблицы shipping_info
CREATE TABLE public.shipping_info(
   shipping_id BIGINT,
   vendor_id BIGINT,
   payment_amount NUMERIC(14, 2),
   shipping_plan_datetime TIMESTAMP,
   shipping_transfer_id BIGINT,
   shipping_agremeent_id BIGINT,
   shipping_country_rate_id BIGINT,
   FOREIGN KEY (shipping_transfer_id) REFERENCES shipping_transfer(id) ON UPDATE CASCADE,
   FOREIGN KEY (shipping_agremeent_id) REFERENCES shipping_agreement(agreement_id) ON UPDATE cascade,
   FOREIGN KEY (shipping_country_rate_id) REFERENCES shipping_country_rates(id) ON UPDATE CASCADE
);

CREATE INDEX shipping_info_shipping_id_index ON public.shipping_info(shipping_id);

--Создание таблицы shipping_status
CREATE TABLE public.shipping_status(
   shipping_id BIGINT,
   status text,
   state text,
   shipping_start_fact_datetime timestamp,
   shipping_end_fact_datetime timestamp,
   PRIMARY KEY (shipping_id)
);

CREATE INDEX shipping_status_shipping_id_index ON public.shipping_status(shipping_id);