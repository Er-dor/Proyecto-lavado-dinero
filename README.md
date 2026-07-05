# Detección de patrones de lavado de dinero en transacciones financieras

Proyecto de análisis de datos orientado a la identificación de comportamientos atípicos asociados a lavado de dinero (AML, *Anti-Money Laundering*) en un dataset sintético de más de un millón de transacciones bancarias internacionales.

El análisis se desarrolla en dos fases: una exploración inicial con **SQL (MySQL)** y una fase de profundización con **Python (Pandas)**, con un roadmap hacia técnicas de *machine learning* para segmentación y detección de anomalías.

> ⚠️ Los datos utilizados son sintéticos. Ninguna cuenta, banco o entidad corresponde a información real.

---

## 📁 Estructura del repositorio

```
├── sql/          # Scripts de creación de esquema, carga y consultas de análisis
├── notebooks/    # Notebooks de Python (EDA y análisis en curso)
├── dashboard/    # Visualizaciones e indicadores
└── docs/         # Documentación y hallazgos (hallazgos.md)
```

---

## 🧱 Fase 1 — Análisis exploratorio con SQL (completada)

**Herramientas:** MySQL Workbench, LOAD DATA INFILE, Python (pandas + SQLAlchemy) para cargas auxiliares.

Se diseñó un esquema relacional con tres tablas: `transf` (transacciones), `accounts` (cuentas) y `banks` (bancos).

### Hallazgos principales

| Hallazgo | Descripción |
|---|---|
| **Cuenta 100428660** | Patrón de *layering* doméstico en EUA: más de 1M de transacciones distribuidas en decenas de bancos. |
| **Cuenta 1004286A8** | *Layering* transfronterizo europeo (España, Italia, Portugal, Francia, Letonia). |
| **Cuenta 1004286F0** | Operación transfronteriza con fragmentación jurisdiccional (China, Francia, EUA). |
| **Pico horario a las 00:00** | Volumen 3x superior al promedio, asociado a *Credit Card* y *Reinvestment*. Hipótesis: integración durante procesos *batch* nocturnos. |
| **Distribución de montos** | Mediana de $1,471 vs. media de $4.4M — presencia de *outliers* extremos. |
| **Posible *structuring*** | En la cuenta 100428660, el 80% de las transacciones está por debajo de $10K (vs. 73% del dataset general). Evidencia sugestiva, no confirmatoria. |

---

## 🐍 Fase 2 — Análisis con Python (en curso)

**Herramientas:** Python, Pandas, NumPy, Matplotlib/Seaborn.

En esta fase el análisis migró de MySQL a Python, trabajando directamente con los CSV en DataFrames para mayor flexibilidad en la exploración.

### Hallazgos nuevos

- **Corporation #140481** (Entity ID `2AA1D8AEFB0`): una sola entidad concentra **8,638 cuentas** distribuidas de forma uniforme (75–185 cuentas por banco) en ~40 bancos cripto, además de un banco en Brasil y otro en Rusia. Pendiente verificar el volumen real de dinero movido.
- **Pico anómalo en el histograma log(Amount Received)** cerca de cero: corresponde a fracciones de Bitcoin. **BTC domina el 79% de las transacciones menores a $1.**
- **Mismatch crítico entre montos**: existen transacciones donde se recibe menos de $1 pero se paga hasta **$225,484** — inconsistencia masiva entre `Amount Received` y `Amount Paid`.
- **Nueva cuenta sospechosa 100428A51**: 52K envíos por debajo de $1 que no habían aparecido en el análisis SQL.

### Roadmap

- [ ] Cerrar la investigación de Corporation #140481 (verificar volumen con merge/filter)
- [ ] Investigar transacciones con mismatch entre `Amount Received` y `Amount Paid`
- [ ] Análisis temporal visual (series por día, boxplots por hora)
- [ ] Detección de cuentas puente por centralidad con **NetworkX**
- [ ] Segmentación de cuentas con **K-Means** (total de transacciones, monto promedio, bancos distintos, países, monedas, actividad nocturna)
- [ ] Detección de anomalías no supervisada con **Isolation Forest**
- [ ] **Regresión logística** para estimar la probabilidad de que una transacción sea sospechosa
- [ ] Validación retrospectiva contra la etiqueta `Is Laundering`

---

## 🛠️ Stack técnico

- **SQL:** MySQL Workbench (esquema relacional, cargas masivas, consultas de análisis)
- **Python:** Pandas, NumPy, SQLAlchemy, Matplotlib/Seaborn
- **Próximamente:** NetworkX, scikit-learn (K-Means, Isolation Forest, regresión logística)

## 📄 Documentación

Los hallazgos detallados de cada fase se documentan en [`docs/hallazgos.md`](docs/hallazgos.md).

---

## 👤 Autor

**Erick Daniel Ortiz Romero** — Físico (UNAM) | Análisis de datos con enfoque en riesgo financiero
📧 erick.danortrom@gmail.com
