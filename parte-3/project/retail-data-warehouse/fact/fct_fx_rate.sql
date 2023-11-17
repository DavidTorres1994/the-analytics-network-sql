-- Table fct.fx_rate

DROP TABLE IF EXISTS fct.fx_rate;

CREATE TABLE IF NOT EXISTS fct.fx_rate
(
                             month DATE primary key
                            , fx_rate_usd_peso DECIMAL
                            , fx_rate_usd_eur DECIMAL
                            , fx_rate_usd_uru  DECIMAL
            ,
             constraint fk_month_fx_rate
             foreign key (month)
             references dim.date(date)
  
);
