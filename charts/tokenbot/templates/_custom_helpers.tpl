{{- define "containerSpec" -}}
{{- $AppVersion := .AppVersion -}}
{{- $ConfigMapData := .configMap.data -}}
{{- $Deployment := .deployment -}}
{{- $SecretData := .secretData -}}
{{- with .containers -}}
{{- range $k, $v := . -}}
- name: {{ $k }}
  {{- with $v }}
  image: "{{ .image.repository }}:{{ .image.tag | default $AppVersion }}"
  imagePullPolicy: {{ .image.pullPolicy }}
  env:
  {{- with $ConfigMapData }}
  {{- range $i, $j := . }}
    - name: {{ $i }}
      valueFrom:
        configMapKeyRef:
          key: {{ $i }}
          name:  tokenbot-{{ $Deployment }}-cm
  {{ end -}}
  {{ end -}}
    {{- with $SecretData }}
  {{- range $i, $j := . }}
    - name: {{ $i }}
      valueFrom:
        secretKeyRef:
          key: {{ $i }}
          name:  tokenbot-{{ $Deployment }}-secrets
  {{ end -}}
  {{ end -}}
  {{- if .env }}
  {{ .env | toYaml | nindent 4}}
  {{- end }}
  ports:
  {{- .ports | toYaml | nindent 4 }}
  {{- if .livenessProbe }}
  livenessProbe:
  {{- .livenessProbe | toYaml | nindent 4 }}
  {{- end }}
  {{- if .readinessProbe }}
  readinessProbe:
  {{- .readinessProbe | toYaml | nindent 4 }}
  {{- end }}
  {{- if .resources }}
  resources:
  {{- .resources | toYaml | nindent 4 }}
  {{- end }}
  {{- if .volumeMounts }}
  volumeMounts:
  {{- .volumeMounts | toYaml | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
