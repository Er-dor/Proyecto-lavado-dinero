
# Hallazgos — AML Intelligence Unit
**Dataset:** IBM Anti-Money Laundering (HI-Medium)  
**Período:** Septiembre 2022  
**Herramientas:** MySQL, Python, Power BI 

## Contexto Dataset
- Total de transacciones: 31,898,238 en 16 días se septiembre del 2022
- Total de cuentas registradas: 2,087,786
- Total de bancos registrados como únicos: 122,333
- Numero de transacciones catalogadas fraudulentas (Laundering) 
>No se tomo en cuenta para el análisis la columna de 'Is Laundering', unicamente para usó de validación.

## Metología 
Para el desarrollo del análisis de datos enfocado en prevención en lavado de dinero se usará el modelo CRISP-DM. Se usará el dataset IBM Anti-Money Laundering, el cual tiene una base de datos sintetica que emula transacciones bancarías tanto legitimas como ilegitimas, en las cuales se usan diferentes tipología de lavado. El proceso que se llevará a cabo siguiendo el modelo es el siguiente.

   &emsp;1.-  Business understanding.
    El problema con el surgimiento de nuevos bancos o SOFIPOs es la facilidad con la que se puede llevar a cabo el lavado de dinero. El objetivo principal es la captación de los principales metodos de lavado de              capital, así mismo la reducción de riesgos financieros y operativos, automatizando la detección disminuyendo los falsos positivos. El proyecto buscará detectar movimientos de riesgo en un ambiento "no controlado"        evitando el uso de la información extra (Columna del dataset 'Is laundering' y el archivo .txt que enlista las tipologías y cuentas involucradas en AML). El exito del proyecto es encontrar la mayor cantidad de cuentas involucradas, asi como la estructuración del modelo que prediga movimiento de alto riesgo.
    
   &emsp;2.-  Data understanding.
    El dataset que se usó es IBM Anti-Money Laundering (HI-Medium), el cual tiene 31,898,238 datos de transacciones bancarias a lo largo de 16 días en septiembre del 2022 y 2,087,786 de cuentas registradas. La base de datos está dividida en 2 documentos csv, una llamada **Transactions** y **Accounts**.  
   Los nombres de las columnas de la tabla Transactions son:  **Timestamp, From_Bank, From_Account, To_Bank,To_Account, Amount Received, Receiving Currency, Amount Paid, Payment Currency, Payment Format, Is Laundering.**   
   Los nombres de las columnas de la tabla de Accounts son:  **Bank Name, Bank ID, Account Number, Entity ID, Entity Name.**   
   La tabla de Transactions presento un problema con respecto a los nombres de las columnas, se tenían columnas con nombres duplicados "Account" y "Account.1" por lo cual se opto por intercambiarlo por un formato mas apto, "From_Account" y "To_Account", con el fin de evitar problemas de relación de variables.  
   En la tabla de accounts se detectaron registros duplicados bajo la columna Account Number, ya que un mismo número de cuenta puede pertenecer a bancos distintos. Por ello se definió una llave primaria compuesta (bank_id + account_number).  
   Adicionalmente, se identificó un subconjunto de transacciones con una discrepancia significativa entre Amount Received y Amount Paid que no se explica por diferencias de tipo de cambio entre divisas. Este patrón se documenta como anomalía estadística; su posible relación con técnicas de lavado se analiza en la sección de hallazgos correspondiente  
   Durante la carga inicial de accounts se detectaron inconsistencias en la interpretación de tipos de dato (bank_id se registraba incorrectamente como 0), resuelto mediante carga controlada vía Python con tipado explícito.

   &emsp;2.-  Data preparation.




  
## Análisis de cuentas por sospecho de lavado de dinero

- Al analizar la cuenta 100428660, se identificó un volumen inusualmente alto de transacciones, predominantemente en dólares (USD). Al segmentar esta actividad, se observó una fuerte dispersión de fondos hacia múltiples entidades bancarias distintas. Este patrón de comportamiento representa una señal de alto riesgo, ya que es un claro indicio de la tipología de lavado de dinero conocida como layering (estratificación), la cual busca ocultar el origen y el rastro de los fondos mediante múltiples transferencias interbancarias

-Al analizar la cuenta '1004286A8', se identificó un volumen inusualmente alto de transacciones, predominando el usó de euros. Al segmentar ahora la actividad financiera, se notó que las tranferencias se hacian a múltiples entidades bancarias internacionales distintas especificamente en España, Italia, Portugal, Francia, Latvia, entre otros. Este patrón representa una señal de alto riesgo, ya que es indicio de la tipología de lavado de dinero de layering, lo peculiar es que es internacional, por lo que sería  cross-border layering, la cual oculta el rastro de los fondos mediante tranferencias bancarias internacionales por los diferentes sistemas financieros y jurisdicciones legales distintas.

-En el caso del cliente 1004286F0 se identificó un comportamiento similar al cliente 1004286A8, teniendo múltiples transacciones bancarías. Al segmentar esta actividad, se observo que las entidades bancarias a las que se dispersaba los fondos bancarios pertenecian a entidades bancarias extranjeras distintas. Este patrón a comparación de los otros perfiles representa una señal de mayor riesgo, ya que  mezcla múltiples jurisdicciones siendo una tipología de lavado de dinero cross-border de fragmentación juridiccional.


>
## Análisis Temporal

Al segmentar transacciones unicamente por hora (formato de 24), se detectó una anomalía significativa: un pico inusual en la cantidad de transacciones a las 12:00 a.m. Se contrastó los horarios laborales de EE. UU., Europa y Asia para descartar la causa regional, manteniendo la distribución de transacciones pero no el volúmen. Al profundizar el análisis de la naturaleza de estas transacciones, se identificó que el pico de medianoche está dominado por movimientos de credit card y reinvestment, en lo contrario con el horario laboral USA y no laboral en Asia/Europ ( 2:00 p.m.) , donde predominan las operaciones con cheques.

En el marco de la prevención de lavado de dinero (AML), el reinvestment es un vehículo clásico para la fase de Integración. La concentración de estas operaciones a la medianoche sugiere un alto riesgo de que actores ilícitos estén utilizando operaciones programadas para ocultar la integración dentro del ruido transaccional masivo de los procesos nocturnos automatizados (batch processing), aprovechando ventanas de tiempo con menor supervisión humana.
