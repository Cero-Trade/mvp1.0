<template>
  <div id="transactions-audit">
    <span class="mb-4 acenter" style="color:#475467 ;font-size: 16px; font-weight: 700;">
      <img src="@/assets/sources/icons/home-layout.svg" alt="Home Icon" style="width: 20px;">
      <img src="@/assets/sources/icons/chevron-right-light.svg" alt="arrow right icon" class="mx-1">
      <span>My portfolio</span>
      <img src="@/assets/sources/icons/chevron-right-light.svg" alt="arrow right icon" class="mx-1">
      <span style="color: #00555B;">Transactions</span>
    </span>
    <h3>Transactions audit</h3>
    <span class="mbb16 mb-6" style="color:#475467;">Here are all the transactions in the system. You can check that all IRECs that have been deposited in our platform have been registered, minted, transfered and burnt.</span>

    <!-- TODO search here -->
    <v-text-field
      v-model="search"
      placeholder="Search transactions by token ID"
      variant="solo"
      density="compact"
      flat
      hide-details
    >
      <template #prepend>
        <img src="@/assets/sources/icons/search.png" alt="search icon">
      </template>
    </v-text-field>

    <div class="divrow jspace flex-wrap" style="row-gap: 10px;">
      <div class="divrow" style="gap: 15px;">

        <v-btn class="btn" @click="dialogFilters = true">
          <img src="@/assets/sources/icons/filter-lines.svg" alt="filter-lines icon">
          Add filter
        </v-btn>
      </div>
    </div>

    <v-data-table
      v-model:items-per-page="itemsPerPage"
      :items-per-page-options="[
        {value: 10, title: '10'},
        {value: 25, title: '25'},
        {value: 50, title: '50'},
      ]"
      :headers="headers"
      :items="filteredDataTransactions"
      :items-length="totalPages"
      :loading="loading"
      class="mt-6 my-data-table"
      @update:options="getData"
    >
      <template #[`item.tx_id`]="{ item }">
        <span class="flex-center wbold" style="color: #475467;">{{ item.tx_id }}</span>
      </template>

      <template #item.type="{ item }">
        <img :src="txTypes[item.type].img" alt="tx type icon">
        <span class="w700">{{ txTypes[item.type].img }}</span>
      </template>

      <template #[`item.addresses`]="{ item }">
        <span>
          <v-menu :close-on-content-click="false" location="bottom center">
            <template #activator="{ props }">
              <a v-bind="props" class="flex-acenter pointer" style="gap: 5px; text-wrap: nowrap; text-decoration: underline !important;">{{ item.recipent.name }}</a>
            </template>

            <v-card class="px-4 py-2 bg-secondary">
              <span>id: {{ item.recipent.principal.toString() }}</span>
            </v-card>
          </v-menu>

          {{ "-->" }}

          <v-menu :close-on-content-click="false" location="bottom center">
            <template #activator="{ props }">
              <a v-bind="props" class="flex-acenter pointer" style="gap: 5px; text-wrap: nowrap; text-decoration: underline !important;">{{ item.sender.name }}</a>
            </template>

            <v-card class="px-4 py-2 bg-secondary">
              <span>id: {{ item.sender.principal.toString() }}</span>
            </v-card>
          </v-menu>
        </span>
      </template>

      <template #[`item.asset_id`]="{ item }">
        <span class="acenter" :title="item.asset_id">{{ shortString(item.asset_id, {}) }} </span>
      </template>

      <template #[`item.tx_index`]="{ item }">
        <!-- TODO here -->
        <a :href="item.tx_index" target="_blank" class="flex-acenter" style="">
          {{ item.tx_index }}
          <img src="@/assets/sources/icons/share.svg" alt="explorer icon">
        </a>
      </template>

      <template #[`item.mwh`]="{ item }">
        <span class="flex-acenter">
          <img src="@/assets/sources/icons/lightbulb.svg" alt="lightbulb icon">
          {{ item.mwh }}
        </span>
      </template>

      <template #[`item.date`]="{ item }">
        <span class="divrow jspace acenter" style="min-width: 100px;">{{ item.date }}</span>
      </template>
    </v-data-table>


    <v-pagination
      v-model="currentPage"
      :length="totalPages"
      :disabled="loading"
      class="mt-4"
      @update:model-value="getData()"
    ></v-pagination>


    <!-- Dialog Filters -->
    <v-dialog v-model="dialogFilters" persistent width="100%" min-width="290" max-width="500">
      <v-form ref="filtersFormRef" @submit.prevent>
        <v-card class="card dialog-card-detokenize d-flex flex-column" style="min-width: 100% !important">
          <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogFilters = false">

          <div class="d-flex mb-2 align-center" style="gap: 10px">
            <v-sheet class="double-sheet">
              <v-sheet>
                <img src="@/assets/sources/icons/filter-lines.svg" alt="filter-lines icon" style="width: 22px">
              </v-sheet>
            </v-sheet>

            <h6 class="mb-0">Filters</h6>
          </div>


          <v-btn
            class="btn mb-4 ml-auto"
            style="background-color: #fff !important; width: max-content !important"
            @click="Object.keys(filters).forEach(e => filters[e] = null)"
          >clear all</v-btn>

          <div class="d-flex mb-7" style="gap: 20px;">
            <v-menu v-model="fromDateMenu" :close-on-content-click="false">
              <template v-slot:activator="{ props }">
                <v-text-field
                  v-model="filters.fromDate"
                  label="Select from date"
                  readonly v-bind="props"
                  variant="outlined"
                  density="compact"
                  class="select"
                  style="flex-basis: 50%;"
                  :rules="[(v) => {
                    if (filters.toDate && !v) return 'Must to select from date'
                    return true
                  }]"
                >
                  <template #append-inner>
                    <img
                      v-if="filters.fromDate"
                      src="@/assets/sources/icons/close.svg"
                      alt="close icon"
                      class="pointer"
                      @click="filters.fromDate = null"
                    >
                  </template>
                </v-text-field>
              </template>

              <v-date-picker
                title=""
                color="rgb(var(--v-theme-secondary))"
                hide-actions
                @update:model-value="(v) => { filters.fromDate = moment(v).format('YYYY/MM/DD') }"
              >
                <template v-slot:header></template>
              </v-date-picker>
            </v-menu>


            <v-menu v-model="toDateMenu" :close-on-content-click="false">
              <template v-slot:activator="{ props }">
                <v-text-field
                  v-model="filters.toDate"
                  label="Select to date"
                  readonly v-bind="props"
                  variant="outlined"
                  density="compact"
                  class="select"
                  style="flex-basis: 50%;"
                  :rules="[(v) => {
                    if (filters.fromDate && !v) return 'Must to select to date'
                    return true
                  }]"
                >
                  <template #append-inner>
                    <img
                      v-if="filters.toDate"
                      src="@/assets/sources/icons/close.svg" alt="close icon"
                      class="pointer"
                      @click="filters.toDate = null"
                    >
                  </template>
                </v-text-field>
              </template>

              <v-date-picker
                title=""
                color="rgb(var(--v-theme-secondary))"
                hide-actions
                @update:model-value="(v) => { filters.toDate = moment(v).format('YYYY/MM/DD') }"
              >
                <template v-slot:header></template>
              </v-date-picker>
            </v-menu>
          </div>

          <v-range-slider
            v-model="filters.mwhRange"
            :min="0"
            :max="1000"
            :step="1"
            variant="solo"
            elevation="0"
            label="Mwh range"
            :thumb-label="filters.mwhRange ? 'always' : false"
            class="align-center mt-3"
            hide-details
          ></v-range-slider>


          <div class="divrow center mt-6" style="gap: 10px;">
            <v-btn class="btn" style="background-color: #fff!important;"  @click="dialogFilters = false">Cancel</v-btn>
            <v-btn class="btn" @click="async () => {
              if (!(await filtersFormRef.validate()).valid) return

              dialogFilters = false;
              getData()
            }" style="border: none!important;">Apply</v-btn>
          </div>
        </v-card>
      </v-form>
    </v-dialog>
  </div>
</template>

<script setup>
import '@/assets/styles/pages/transactions-audit.scss'

import { ref, watch } from 'vue'
import { AgentCanister } from '@/repository/agent-canister'
import { TxType } from '@/models/transaction-model'
import plusCircle from '@/assets/sources/icons/plus-circle.svg'
import minusCircle from '@/assets/sources/icons/minus-circle.svg'
import arrowCircleBrokenRight from '@/assets/sources/icons/arrow-circle-broken-right.svg'
import { useToast } from 'vue-toastification'
import moment from "moment";
import { shortString } from '@/plugins/functions'

const
  toast = useToast(),

operationTypes = {
  mint: {
    value: 'Mint',
    img: plusCircle
  },
  transfer: {
    value: 'Mint',
    img: arrowCircleBrokenRight
  },
  burn: {
    value: 'Mint',
    img: minusCircle
  }
},
txTypes = {
  [TxType.purchase]: operationTypes.mint,
  [TxType.redemption]: operationTypes.burn,
  [TxType.putOnSale]: operationTypes.transfer,
  [TxType.takeOffMarketplace]: operationTypes.transfer,
},
search = ref(null),
headers = [
  { title: 'Type', key: 'type', sortable: false },
  { title: 'Token ID', key: 'asset_id', sortable: false },
  { title: 'From / To', key: 'addresses', sortable: false, width: "110px" },
  { title: 'MWh', key: 'mwh', sortable: false },
  { title: 'Transaction hash', key: 'tx_index', align: 'center', sortable: false },
  { title: 'Timestamp', key: 'date', sortable: false },
],
dataTransactions = ref([]),
loading = ref(true),
currentPage = ref(1),
itemsPerPage = ref(50),
totalPages = ref(1),

dialogFilters = ref(),
filtersFormRef = ref(),
filters = ref({
  mwhRange: null,
  fromDate: null,
  toDate: null,
}),

fromDateMenu = ref(),
toDateMenu = ref(),


filteredDataTransactions = computed(() => {
  if (!search.value) return dataTransactions.value;

  return dataTransactions.value.filter(e => e.asset_id.includes(search.value))
})



watch(fromDateMenu, (value) => {
  if (!value) filtersFormRef.value.validate()
})

watch(toDateMenu, (value) => {
  if (!value) filtersFormRef.value.validate()
})


async function getData() {
  loading.value = true

  // map dates
  let rangeDates
  if (filters.value.fromDate && filters.value.toDate)
    rangeDates = [new Date(filters.value.fromDate), new Date(filters.value.toDate)]

  try {
    // get getPortfolio
    const { data, total } = await AgentCanister.getTransactions({
      length: itemsPerPage.value,
      page: currentPage.value,
      mwhRange: filters.value.mwhRange,
      method: filters.value.method,
      rangeDates,
    }),
    list = []

    for (const item of data) {
      list.push({
        type: item.txType,
        recipent: item.to || "---",
        sender: item.from || "---",
        mwh: item.tokenAmount,
        asset_id: item.assetInfo.tokenId,
        date: item.date.toDateString(),
        tx_index: item.txIndex || "---",
      })
    }

    dataTransactions.value = list.sort((a, b) => a.tx_id - b.tx_id)
    totalPages.value = total
  } catch (error) {
    console.error(error);
    toast.error(error)
  }

  loading.value = false
}
</script>
