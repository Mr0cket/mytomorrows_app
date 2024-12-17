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
{{- define "mytomorrows.labels" -}}
helm.sh/chart: {{ include "mytomorrows.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}



{{- define "mytomorrows.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mytomorrows.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "mytomorrows.podLabels" -}}
{{- include "mytomorrows.selectorLabels" . | nindent 4 }}
{{- with .Values.podLabels }}
{{- toYaml . | nindent 4 }}
{{- end -}}
{{- end -}}