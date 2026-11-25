# Politicas propias de Checkov

Regla de la organizacion: **todo recurso de red o de almacenamiento debe poder
rastrearse**. En la practica se exigen dos etiquetas:

| ID | Regla | Recursos alcanzados |
|----|-------|---------------------|
| `CKV2_ORG_101` | Debe existir la etiqueta `Owner` | `aws_security_group`, `aws_ebs_volume`, `aws_network_interface` |
| `CKV2_ORG_102` | `Environment` solo admite `dev` o `prod` | `aws_security_group`, `aws_ebs_volume`, `aws_network_interface` |

Cada check es un archivo YAML independiente y se carga con
`--external-checks-dir politicas`, que ya esta en el paso
`Gate Checkov` de `.github/workflows/iac-security.yml`.

## Por que esta regla

Sin `Owner` no se puede asignar el costo ni avisar al responsable cuando aparece
un hallazgo. Sin un `Environment` acotado, los inventarios y los tableros de
costo reciben valores libres (`prod`, `produccion`, `PROD`, `produccion-2`) y las
consultas dejan de ser confiables. Es una regla de gobierno, no de seguridad
tecnica, y es justamente el tipo de control que las herramientas no traen de
fabrica.

## Caso que falla y caso que pasa

Los dos casos son minimos y solo contienen recursos de los tipos alcanzados por
la politica, para aislar el resultado:

```bash
# Falla: 4 hallazgos (2 recursos x 2 reglas)
checkov -d politicas/ejemplos/falla --external-checks-dir politicas \
  --check CKV2_ORG_101,CKV2_ORG_102 --compact

# Pasa: 4 checks en verde y ningun fallo
checkov -d politicas/ejemplos/pasa --external-checks-dir politicas \
  --check CKV2_ORG_101,CKV2_ORG_102 --compact
```

Resultado esperado:

| Caso | Passed | Failed | Exit |
|------|--------|--------|------|
| `politicas/ejemplos/falla` | 0 | 4 | 1 |
| `politicas/ejemplos/pasa` | 4 | 0 | 0 |

`infra/main.tf` todavia no cumple la politica: el security group, la interfaz de
red y el volumen no tienen etiquetas. Esos hallazgos (`CKV2_ORG_101` y
`CKV2_ORG_102`) se corrigen en el PR de remediacion junto con el resto.

Nota: los casos de ejemplo estan fuera de las carpetas que escanea el pipeline
(`infra`, `ansible`, `docker`), asi que no alteran el gate. Si se corre
`checkov -d .` sobre todo el repositorio hay que excluirlos con
`--skip-path politicas/ejemplos`, de lo contrario apareceran como fallas
intencionales.

## Excepcion documentada

En `infra/main.tf`, dentro del recurso `aws_ebs_volume.datos`, hay una unica
excepcion:

```hcl
#checkov:skip=CKV_AWS_189:<justificacion> Aprobacion: ... Vence: 2027-06-30
```

`CKV_AWS_189` pide una CMK dedicada; el volumen si queda cifrado (lo verifica
`CKV_AWS_3`), pero con la clave administrada `aws/ebs`. El comentario debe ir
**dentro** del bloque: en Checkov 3.4.5 la forma anterior al recurso no aplica el
skip en Terraform.
