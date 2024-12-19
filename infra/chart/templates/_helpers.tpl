{{/*
Expand the name of the chart.
*/}}
{{- define "mytomorrows.name" -}}
{{- default .Chart.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "mytomorrows.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}

{{- define "mytomorrows.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mytomorrows.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "mytomorrows.labels" -}}
helm.sh/chart: {{ include "mytomorrows.chart" . }}
{{- include "mytomorrows.selectorLabels" . | nindent 0 }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{- toYaml . | nindent 0 }}
{{- end -}}
{{- end }}