{{- define "afn.app-chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "afn.app-name" -}}
{{- .appName }}
{{- end }}

{{- define "afn.app-labels" -}}
helm.sh/chart: {{ include "afn.app-chart" . }}
{{ include "afn.app-selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "afn.app-selectorLabels" -}}
app.kubernetes.io/name: {{ include "afn.app-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

