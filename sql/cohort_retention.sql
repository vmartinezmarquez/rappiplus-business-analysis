-- RappiPlus
-- Retención de usuarios por cohortes
-- Agrupa usuarios por mes de registro y calcula retención a 7, 14 y 21 días.

WITH usuarios_cohorte AS (
    SELECT
        id_usuario,
        DATE_TRUNC(
            'month',
            CAST(fecha_registro AS DATE)
        )::DATE AS cohorte
    FROM users
),

tamano_cohorte AS (
    SELECT
        cohorte,
        COUNT(DISTINCT id_usuario) AS usuarios_iniciales
    FROM usuarios_cohorte
    GROUP BY cohorte
),

usuarios_retenidos AS (
    SELECT
        uc.cohorte,

        COUNT(DISTINCT CASE
            WHEN ua.dias_despues_registro = 7
                 AND ua.activo = 1
            THEN uc.id_usuario
        END) AS retenido_w1,

        COUNT(DISTINCT CASE
            WHEN ua.dias_despues_registro = 14
                 AND ua.activo = 1
            THEN uc.id_usuario
        END) AS retenido_w2,

        COUNT(DISTINCT CASE
            WHEN ua.dias_despues_registro = 21
                 AND ua.activo = 1
            THEN uc.id_usuario
        END) AS retenido_w3

    FROM usuarios_cohorte AS uc
    LEFT JOIN user_activity AS ua
        ON uc.id_usuario = ua.id_usuario
    GROUP BY uc.cohorte
)

SELECT
    tc.cohorte,
    tc.usuarios_iniciales,
    ur.retenido_w1,
    ur.retenido_w2,
    ur.retenido_w3,

    ROUND(
        ur.retenido_w1 * 100.0
        / tc.usuarios_iniciales,
        2
    ) AS semana_1,

    ROUND(
        ur.retenido_w2 * 100.0
        / tc.usuarios_iniciales,
        2
    ) AS semana_2,

    ROUND(
        ur.retenido_w3 * 100.0
        / tc.usuarios_iniciales,
        2
    ) AS semana_3

FROM tamano_cohorte AS tc
JOIN usuarios_retenidos AS ur
    ON tc.cohorte = ur.cohorte
ORDER BY tc.cohorte;
