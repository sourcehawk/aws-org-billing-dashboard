{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- if .Values.defaultLabels }}
{{ range $key, $value := .Values.defaultLabels }}
{{- $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Dashboard labels
*/}}
{{- define "dashboard.labels" -}}
{{ include "common.labels" . }}
{{- if .Values.dashboard.labels }}
{{ range $key, $value := .Values.dashboard.labels }}
{{- $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Datasource labels
*/}}
{{- define "datasource.labels" -}}
{{ include "common.labels" . }}
{{- if .Values.datasource.labels }}
{{ range $key, $value := .Values.datasource.labels }}
{{- $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Dashboard annotations
*/}}
{{- define "dashboard.annotations" -}}
{{- if .Values.dashboard.annotations }}
{{ range $key, $value := .Values.dashboard.annotations }}
{{- $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

