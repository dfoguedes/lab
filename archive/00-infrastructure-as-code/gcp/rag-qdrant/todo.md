# Todo

- Criar cluster de k8s (no pequeno)
- instalar o helm do qdrant
- Instalar o n8n em k8s
- Ingerir o pdf e mandar para o qdrant

3. O Fluxo de Dados (A Ingestão)

Trigger: Recebe o PDF.

Processamento: O n8n parte o PDF em "chunks".

Embeddings: O n8n envia para o Azure OpenAI (via API) para converter texto em vetores.

Armazenamento: O n8n envia esses vetores para o Qdrant que está no teu cluster.
