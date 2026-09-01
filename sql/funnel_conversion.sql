-- RappiPlus
-- Funnel de conversión de usuarios
-- Analiza el avance secuencial desde first_visit hasta purchase.

WITH first_visit AS (
    SELECT
        id_usuario,
        MIN(timestamp_evento) AS fecha_first_visit
    FROM events
    WHERE nombre_evento = 'first_visit'
    GROUP BY id_usuario
),

select_item AS (
    SELECT
        e.id_usuario,
        MIN(e.timestamp_evento) AS fecha_select_item
    FROM events e
    INNER JOIN first_visit f
        ON e.id_usuario = f.id_usuario
    WHERE e.nombre_evento = 'select_item'
      AND e.timestamp_evento >= f.fecha_first_visit
    GROUP BY e.id_usuario
),

add_to_cart AS (
    SELECT
        e.id_usuario,
        MIN(e.timestamp_evento) AS fecha_add_to_cart
    FROM events e
    INNER JOIN select_item s
        ON e.id_usuario = s.id_usuario
    WHERE e.nombre_evento = 'add_to_cart'
      AND e.timestamp_evento >= s.fecha_select_item
    GROUP BY e.id_usuario
),

begin_checkout AS (
    SELECT
        e.id_usuario,
        MIN(e.timestamp_evento) AS fecha_begin_checkout
    FROM events e
    INNER JOIN add_to_cart a
        ON e.id_usuario = a.id_usuario
    WHERE e.nombre_evento = 'begin_checkout'
      AND e.timestamp_evento >= a.fecha_add_to_cart
    GROUP BY e.id_usuario
),

add_payment_info AS (
    SELECT
        e.id_usuario,
        MIN(e.timestamp_evento) AS fecha_add_payment_info
    FROM events e
    INNER JOIN begin_checkout b
        ON e.id_usuario = b.id_usuario
    WHERE e.nombre_evento = 'add_payment_info'
      AND e.timestamp_evento >= b.fecha_begin_checkout
    GROUP BY e.id_usuario
),

purchase AS (
    SELECT
        e.id_usuario,
        MIN(e.timestamp_evento) AS fecha_purchase
    FROM events e
    INNER JOIN add_payment_info p
        ON e.id_usuario = p.id_usuario
    WHERE e.nombre_evento = 'purchase'
      AND e.timestamp_evento >= p.fecha_add_payment_info
    GROUP BY e.id_usuario
)

SELECT 'first_visit' AS etapa, COUNT(*) AS usuarios
FROM first_visit

UNION ALL

SELECT 'select_item', COUNT(*)
FROM select_item

UNION ALL

SELECT 'add_to_cart', COUNT(*)
FROM add_to_cart

UNION ALL

SELECT 'begin_checkout', COUNT(*)
FROM begin_checkout

UNION ALL

SELECT 'add_payment_info', COUNT(*)
FROM add_payment_info

UNION ALL

SELECT 'purchase', COUNT(*)
FROM purchase;
