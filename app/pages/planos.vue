<script setup lang="ts">
const handleSubscribeClassic = () => {
  console.log('Assinar Plano Clássico')
}

const handleSubscribePremium = () => {
  console.log('Assinar Plano Premium')
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-orange-50 via-orange-100 to-orange-200">
    <div class="container mx-auto px-4 py-8">
      <!-- Cabeçalho -->
      <div class="text-center mb-8 space-y-2">
        <h1 class="text-4xl font-bold text-secondary">
          Escolha seu Plano
        </h1>
        <p class="text-lg text-muted">
          1 pizza gigante por semana com os melhores sabores
        </p>
      </div>

      <!-- Grid de Planos -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-6xl mx-auto">
        <!-- Plano Clássico -->
        <PlanCard
          plan-name="Plano Clássico"
          description="Os sabores tradicionais que você ama"
          price="R$ 79,90"
          price-label="por mês"
          icon-bg-color="bg-red-100"
          flavors-title="Sabores disponíveis:"
          :flavors="[
            'Calabresa - Mussarela e calabresa fatiada',
            'Frango com Catupiry - Mussarela, frango e catupiry',
            'Napolitana - Mussarela, tomate e parmesão',
            'Portuguesa - Mussarela, presunto, cebola, azeitona e ovos'
          ]"
          :info-labels="[
            'Escolha até 2 sabores por pizza',
            '1 pizza gigante por semana'
          ]"
          action-button-label="Assinar Plano Clássico"
          action-button-variant="secondary"
          @subscribe="handleSubscribeClassic"
        />

        <!-- Plano Premium -->
        <PlanCard
          plan-name="Plano Premium"
          description="Sabores especiais + todos os clássicos"
          price="R$ 119,90"
          price-label="por mês"
          icon-bg-color="bg-orange-200"
          is-popular
          border-color="border-yellow-400"
          flavors-title="Sabores especiais:"
          :flavors="[
            'Frango Especial - Mussarela, batata palha, frango, creme de leite e bacon',
            '4 Queijos com Bacon - Mussarela, provolone, parmesão, catupiry e bacon',
            'Champignon - Mussarela e champignon',
            'Pizza Curitiba - Mussarela, bacon, presunto, calabresa, milho, cebola e tomate',
            '+ Todos os sabores do Plano Clássico'
          ]"
          :info-labels="[
            'Escolha até 2 sabores por pizza',
            '1 pizza gigante por semana'
          ]"
          action-button-label="Assinar Plano Premium"
          action-button-variant="secondary"
          @subscribe="handleSubscribePremium"
        />
      </div>
    </div>
  </div>
</template>
