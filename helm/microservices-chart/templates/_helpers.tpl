{{- define "microservices-chart.fullname" -}}
{{ printf "%s" .Release.Name }}
{{- end -}}

