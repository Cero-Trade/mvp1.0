<!-- TODO review searching antyhing missing -->

<template>
  <div id="settings">
    <span class="mb-10 acenter" style="color:#475467 ;font-size: 16px; font-weight: 700;">
      <img src="@/assets/sources/icons/home-layout.svg" alt="Home Icon" style="width: 20px;">
      <img src="@/assets/sources/icons/chevron-right-light.svg" alt="arrow right icon" class="mx-1">
      <span style="color: #00555B;">Settings</span>
    </span>
    <h3>Settings</h3>
    <span class="mb-16" style="color:#475467; max-width: 774px">
      Customize your Cero Trade experience. Manage your company information, set notification preferences, update beneficiary accounts, and select your preferred payment methods here.
    </span>

    <v-row>
      <v-col xl="4" lg="4" md="4" sm="6" cols="12">
        <v-card class="card" style="background-color: #F9FAFB!important;">
          <div class="flex-space-center mb-7" style="gap: 20px">
            <img src="@/assets/sources/icons/info-circle.svg" alt="info-circle icon">

            <v-btn class="btn" @click="getUserId">Copy User ID</v-btn>
          </div>

          <h5 class="mb-6">Company information</h5>
          <span class="tertiary" style="font-weight: 300;">
            Update your company details to ensure accurate representation in all transactions and communications. Keep your profile current for seamless business operations.
          </span>

          <v-btn class="btn mt-6" @click="dialogCompany = true">
            Edit personal information
            <img src="@/assets/sources/icons/user-edit.svg" alt="user-edit icon">
          </v-btn>
        </v-card>
      </v-col>

      <v-col xl="4" lg="4" md="4" sm="6" cols="12">
        <v-card class="card" style="background-color: #F9FAFB!important;">
          <img src="@/assets/sources/icons/headphones-black.svg" alt="headphones icon" class="mb-7">
          <h5 class="mb-6">Support</h5>
          <span class="tertiary" style="font-weight: 300;">
            Contact our Cero Trade team for any needed support.
          </span>
          <v-btn class="btn mt-6" @click="$router.push('/support')">
            Contact Support
            <img src="@/assets/sources/icons/headphones-black.svg" alt="headphones icon" style="width: 15px">
          </v-btn>
        </v-card>
      </v-col>

      <v-col xl="4" lg="4" md="4" sm="6" cols="12">
        <v-card class="card" style="background-color: #F9FAFB!important;">
          <img src="@/assets/sources/icons/domain.svg" alt="Domain" class="mb-10" style="width: 25px;">
          <h5 class="mb-6">Beneficiary accounts</h5>
          <span class="tertiary" style="font-weight: 300;">
            Securely manage and edit your beneficiary accounts to streamline your redemptions.
          </span>
          <v-btn :loading="!beneficiaries" class="btn mt-6" @click="dialogBeneficiary = true">
            Edit accounts
            <img src="@/assets/sources/icons/pencil.svg" alt="pencil icon">
          </v-btn>
        </v-card>
      </v-col>

      <!-- <v-col xl="4" lg="4" md="4" sm="6" cols="12">
        <v-card class="card flex-column" style="background-color: #F9FAFB!important; --h: 100%">
          <img src="@/assets/sources/icons/wallet.svg" alt="wallet icon" class="mb-10" style="width: 20px">
          <h5 class="mb-6">Select Prefered Payment</h5>
          <span class="tertiary" style="font-weight: 300;">
            Connect your wallet or include your bank transfer details.
          </span>
          <v-btn class="btn mt-auto mr-auto" @click="dialogSelectPayment = true">
            Connect
            <img src="@/assets/sources/icons/plus.svg" alt="plus icon">
          </v-btn>
        </v-card>
      </v-col> -->

      <v-col xl="4" lg="4" md="4" sm="6" cols="12">
        <v-card class="card flex-column" style="background-color: #F9FAFB!important; --h: 100%">
          <img src="@/assets/sources/icons/trash.svg" alt="trash icon" class="mb-10" style="width: 20px">
          <h5 class="mb-6">Delete account</h5>
          <span class="tertiary" style="font-weight: 300;">
            Delete acocunt from Cero Trade registration.
          </span>
          <v-btn class="btn mt-auto mr-auto" style="background-color: #D92D2099!important" @click="dialogDeleteAccount = true">
            Delete
            <img src="@/assets/sources/icons/trash.svg" alt="trash icon">
          </v-btn>
        </v-card>
      </v-col>
    </v-row>


    <!-- Dialog information -->
    <v-dialog v-model="dialogCompany" persistent>
      <v-form ref="formProfileRef" @submit.prevent>
        <v-card class="card card-dialog-company">
          <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogCompany = false">
          <v-sheet class="mb-10 double-sheet">
            <v-sheet>
              <img src="@/assets/sources/icons/users.svg" alt="users icon">
            </v-sheet>
          </v-sheet>
          <h5>Company information</h5>
          <span class="tertiary">Add a trusted company you want to redeem IRECS to to your list of trusted beneficiaries.</span>

          <v-file-input
            id="profileCompanyLogo"
            v-model="formProfile.companyLogo"
            type="file"
            accept="image/*"
            class="d-none"
            :rules="[globalRules.required]"
            @change="({ target }) => {
              const [file] = target.files
              if (file) profileCompanyLogo = getUrlFromFile(file)
            }"
          ></v-file-input>
          <label for="profileCompanyLogo" class="divrow mt-4 mb-6 acenter" style="gap: 15px; width: max-content;">
            <v-card width="70" height="60" elevation="0" class="outlined d-flex flex-center pa-1">
              <v-progress-circular
                v-if="!profileCompanyLogo"
                indeterminate
                size="30"
                color="rgb(var(--v-theme-primary))"
              ></v-progress-circular>
              <img v-else :src="profileCompanyLogo" alt="Logo" style="width: 100%; height: 100%; border-radius: inherit; object-fit: cover;">
            </v-card>

            <span style="color: #667085;">
              <img src="@/assets/sources/icons/cloud-upload.svg" alt="Logo" style="width: 15px;">
              Replace Company Logo
            </span>
          </label>

          <v-row>
            <v-col xl="6" lg="6" cols="12">
              <label for="company-name">Company name</label>
              <v-text-field
                id="company-name"
                v-model="formProfile.companyName"
                class="input" variant="solo" flat elevation="0"
                placeholder="ABC Company"
                :rules="[globalRules.required]"
              ></v-text-field>
            </v-col>

            <v-col xl="6" lg="6" cols="12">
              <label for="company-id">Company ID</label>
              <v-text-field
                id="company-id"
                v-model="formProfile.companyId"
                class="input" variant="solo" flat elevation="0"
                placeholder="0000000000"
                :rules="[globalRules.required]"
              ></v-text-field>
            </v-col>

            <v-col xl="6" lg="6" cols="12">
              <label for="city">City</label>
              <v-text-field
                id="city"
                v-model="formProfile.city"
                class="input" variant="solo" flat elevation="0"
                placeholder="New York"
                :rules="[globalRules.required]"
              ></v-text-field>
            </v-col>

            <v-col xl="6" lg="6" cols="12">
              <label for="country">Country</label>
              <v-autocomplete
                id="country" v-model="formProfile.country"
                class="input" variant="solo" flat elevation="0"
                placeholder="USA"
                menu-icon=""
                :items="Object.values(countries)"
                item-title="name"
                item-value="code"
                :rules="[globalRules.required]"
              >
                <template #append-inner="{ isFocused }">
                  <img
                    src="@/assets/sources/icons/chevron-down.svg"
                    alt="chevron-down icon"
                    :style="`transform: ${isFocused.value ? 'rotate(180deg)' : 'none'};`"
                  >
                </template>

                <template #selection="{ item }">
                  <v-img-load
                    :src="item.raw.flag.toString()"
                    :alt="`${item.raw.name} logo`"
                    cover
                    sizes="25px"
                    rounded="50%"
                    class="flex-grow-0"
                  />
                  <span class="bold ml-2 ellipsis-text">{{ item.raw.name }}</span>
                </template>

                <template #item="{ item, props }">
                  <v-list-item v-bind="props" title=" ">
                    <div class="d-flex align-center">
                      <v-img-load
                        :src="item.raw.flag.toString()"
                        :alt="`${item.raw.name} logo`"
                        cover
                        sizes="25px"
                        rounded="50%"
                        class="flex-grow-0"
                      />
                      <span class="bold ml-2" style="translate: 0 1px">{{ item.raw.name }}</span>
                    </div>
                  </v-list-item>
                </template>
              </v-autocomplete>
            </v-col>

            <v-col cols="12">
              <label for="address">Company address</label>
              <v-text-field
                id="address"
                v-model="formProfile.address"
                class="input" variant="solo" flat elevation="0"
                :rules="[globalRules.required]"
              ></v-text-field>
            </v-col>

            <v-col cols="12">
              <label for="email">Email</label>
              <v-text-field
                id="email"
                v-model="formProfile.email"
                class="input" variant="solo" flat elevation="0"
                placeholder="office@abccompany.com"
                :rules="[globalRules.email]"
              ></v-text-field>
            </v-col>
          </v-row>

          <div class="divrow mt-6" style="gap: 10px;">
            <v-btn class="btn" style="background-color: #fff!important;"  @click="dialogCompany = false">
              Cancel
              <img src="@/assets/sources/icons/close.svg" alt="close" style="width: 15px">
            </v-btn>
            <v-btn :loading="loadingFormProfile" class="btn" @click="saveProfileInfo" style="border: none!important;">
              Save changes
              <img src="@/assets/sources/icons/save.svg" alt="save icon">
            </v-btn>
          </div>
        </v-card>
      </v-form>
    </v-dialog>
    
    <!-- Dialog Select Payment -->
    <v-dialog v-model="dialogSelectPayment" persistent>
      <v-card class="card card-dialog-notification">
        <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogSelectPayment = false">
        <v-sheet class="mb-6 double-sheet">
          <v-sheet>
            <img src="@/assets/sources/icons/wallet.svg" alt="wallet icon" style="width: 20px">
          </v-sheet>
        </v-sheet>
        <h5 class="bold">Select prefered payment</h5>
        <span class="tertiary">
          You can choose to pay by bank transfer or with your ICP tokens. Connect directly to your wallet or access our bank transfer providers.
        </span>

        <div
          v-for="(item, i) in payments"
          :key="i"
          class="div-radio-sell flex-column align-start"
          style="cursor: default !important; gap: 15px"
        >
          <img :src="item.icon" :alt="`${item.name} icon`" :style="`width: ${item.width}px`">

          <span class="bold">{{ item.name }}</span>

          <v-btn class="btn2" @click="onConnectPayment(item)">Connect</v-btn>
        </div>
      </v-card>
    </v-dialog>
    
    <!-- Dialog bank details -->
    <v-dialog v-model="dialogBankTransferDetails" persistent>
      <v-card class="card card-dialog-company" style="width: min(100%, 600px) !important">
        <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogBankTransferDetails = false">
        <v-sheet class="mb-10 double-sheet">
          <v-sheet>
            <img src="@/assets/sources/icons/credit-card.svg" alt="credit-card icon">
          </v-sheet>
        </v-sheet>
        <h5>Bank transfer details</h5>

        <div class="flex-column mb-5" style="gap: 5px">
          <label for="account">Account owner name</label>
          <v-text-field
            id="account"
            variant="solo"
            flat
            class="input"
            placeholder="olivia@untitledui.com"
          />
        </div>
        
        <div class="flex-column mb-5" style="gap: 5px">
          <label for="country">Country</label>
          <v-select
            id="country"
            variant="solo"
            flat
            menu-icon=""
            class="input"
            placeholder="United Kingdom"
          >
            <template #append-inner="{ isFocused }">
              <img
                src="@/assets/sources/icons/chevron-down.svg"
                alt="chevron-down icon"
                :style="`transform: ${isFocused.value ? 'rotate(180deg)' : 'none'};`"
              >
            </template>
          </v-select>
        </div>
        
        <div class="flex-column mb-5" style="gap: 5px">
          <label for="number">Account number</label>
          <v-text-field
            id="number"
            variant="solo"
            flat
            class="input"
            placeholder="Card number"
            hint="This is a hint text to help the user"
            append-inner-icon="mdi-help-circle-outline"
          />
        </div>
        
        <aside class="d-flex flex-wrap mb-5" style="column-gap: 20px">
          <div class="flex-column flex-grow-1" style="gap: 5px; flex-basis: 150px">
            <label for="bank">Select Bank</label>
            <v-text-field
              id="bank"
              variant="solo"
              flat
              class="input"
              placeholder="BANCO BICE"
            />
          </div>
          
          
          <div class="flex-column flex-grow-1" style="gap: 5px; flex-basis: 150px">
            <label for="id-number">Enter ID number</label>
            <v-text-field
              id="id-number"
              variant="solo"
              flat
              menu-icon="mdi-chevron-down"
              class="input"
              placeholder="19605978-4"
              hint="This is a hint text to help the user"
              append-inner-icon="mdi-help-circle-outline"
            />
          </div>
        </aside>

        <div class="divrow mt-6" style="gap: 10px;">
          <v-btn class="btn" style="background-color: #fff!important;"  @click="dialogBankTransferDetails = false">
            Cancel
            <img src="@/assets/sources/icons/close.svg" alt="close" style="width: 15px">
          </v-btn>
          <v-btn class="btn" @click="dialogBankTransferDetails = false;" style="border: none!important;">
            Confirm
            <img src="@/assets/sources/icons/check-simple.svg" alt="check icon">
          </v-btn>
        </div>
      </v-card>
    </v-dialog>

    
    <!-- Dialog delete account -->
    <v-dialog v-model="dialogDeleteAccount" persistent>
      <v-card class="card card-dialog-company" style="width: min(100%, 350px) !important">
        <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogDeleteAccount = false">
        <v-sheet class="mb-10 double-sheet">
          <v-sheet>
            <img src="@/assets/sources/icons/trash.svg" alt="trash icon">
          </v-sheet>
        </v-sheet>
        <h5>Delete account</h5>

        <p>
          Are you sure that wanna delete your account? this action will burn all tokens you owned in the platform
        </p>

        <div class="divrow mt-6" style="gap: 10px;">
          <v-btn class="btn" style="background-color: #fff!important;"  @click="dialogDeleteAccount = false">
            Cancel
            <img src="@/assets/sources/icons/close.svg" alt="close" style="width: 15px">
          </v-btn>
          <v-btn class="btn" @click="deleteAccount()" style="border: none!important;">
            Confirm
            <img src="@/assets/sources/icons/check-simple.svg" alt="check icon">
          </v-btn>
        </div>
      </v-card>
    </v-dialog>

    <!-- Dialog Beneficiary Account -->
    <v-dialog v-model="dialogBeneficiary" persistent>
      <v-card class="card card-dialog-notification">
        <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogBeneficiary = false">
        <v-sheet class="mb-6 double-sheet">
          <v-sheet>
            <img src="@/assets/sources/icons/domain.svg" alt="Domain" style="width: 25px;">
          </v-sheet>
        </v-sheet>
        <h5 class="bold">Beneficiary accounts</h5>
        <span class="tertiary">These are all companies you can redeem certificates in the name of.</span>

        <div class="div-radio-sell mb-0" v-for="(item, index) in beneficiaries" :key="index">
          <v-sheet class="double-sheet">
            <v-sheet>
              <img :src="item.companyLogo" alt="avatar image" style="width: 20px">
            </v-sheet>
          </v-sheet>
          <div class="divcol ml-6">
            <span class="bold">{{ item.companyName }}</span>
          </div>
        </div>

        <div class="div-radio-sell" @click="dialogNewBeneficiary = true; dialogBeneficiary = false">
          <v-sheet class="double-sheet">
            <v-sheet>
              <img src="@/assets/sources/icons/plus-square.svg" alt="plus-square icon" style="width: 20px">
            </v-sheet>
          </v-sheet>
          <div class="divcol ml-6">
            <span class="bold">Add an account</span>
            <span>Add any other Cero Trade user to your beneficiary list in order to redeem assets to their name.</span>
          </div>
        </div>

        <div class="div-radio-sell" @click="beneficiaryUrl.copyToClipboard('beneficiary link copied to clipboard')">
          <v-sheet class="double-sheet">
            <v-sheet>
              <img src="@/assets/sources/icons/plus-square.svg" alt="plus-square icon" style="width: 20px">
            </v-sheet>
          </v-sheet>
          <div class="divcol ml-6">
            <span class="bold">Share beneficiary link</span>
            <span>Share a link with your beneficiary to register it linked to you</span>
          </div>
        </div>
      </v-card>
    </v-dialog>

    <!-- New Beneficiary Account -->
    <v-dialog v-model="dialogNewBeneficiary" persistent>
      <v-card class="card card-dialog-company">
        <img src="@/assets/sources/icons/close.svg" alt="close icon" class="close" @click="dialogNewBeneficiary = false">
        <v-sheet class="mb-10 double-sheet">
          <v-sheet>
            <img src="@/assets/sources/icons/domain.svg" alt="Domain" style="width: 25px;">
          </v-sheet>
        </v-sheet>
        <h5 class="bold">New beneficiary account</h5>
        <span class="tertiary mb-4">Adding a new beneficiary will allow you to redeem certificates to their name.</span>

        <v-form ref="formBeneficiaryRef" v-model="formBeneficiaryValid" @submit.prevent>
          <v-row>
            <v-col cols="12">
              <label for="beneficiary-account">Beneficiary account</label>
              <v-text-field 
              v-model="formBeneficiary.search"
              id="beneficiary-account" class="input" 
              variant="solo" flat elevation="0" placeholder="Search by account name or account id"
              @keyup="({ key }) => {
                if (key !== 'Enter') return
                searchBeneficiaries()
              }"
              >
                <template #append>
                  <v-btn
                    :loading="loadingSearchBeneficiary"
                    @click="searchBeneficiaries"
                  >
                    <img src="@/assets/sources/icons/search.png" alt="search icon" style="width: 20px">
                  </v-btn>
                </template>
              </v-text-field>

              <v-text-field v-model="formBeneficiary.beneficiary" :rules="[globalRules.required]" class="d-none" />
            </v-col>

            <v-col cols="12">
              <v-card height="400" class="px-3 py-4 mt-0 d-flex flex-column align-center justify-start" style="overflow-y: auto; overflow-x: hidden;">
                <span v-if="!formBeneficiary.beneficiaries">Waiting for search...</span>
                <span v-else-if="!formBeneficiary.beneficiaries.length">No matches found</span>

                <div
                  v-for="(item, i) in formBeneficiary.beneficiaries" :key="i"
                  class="div-radio-sell mt-0 mb-4"
                  :class="{ active: formBeneficiary.beneficiary === item.principalId }"
                  style="width: 100% !important"
                  @click="getBeneficiaryProfile(item.principalId, i)"
                >
                  <v-sheet class="double-sheet">
                    <v-sheet>
                      <v-progress-circular
                        v-if="!item.companyLogo"
                        :indeterminate="item.loading"
                      ></v-progress-circular>
                      <v-img-load
                        v-else
                        :src="item.companyLogo"
                        :alt="`${item.companyName} logo`"
                        cover
                        sizes="30px"
                        rounded="50%"
                        class="flex-grow-0"
                      />
                    </v-sheet>
                  </v-sheet>
                  <div class="divcol ml-6">
                    <span class="bold">{{ item.companyName }}</span>
                  </div>
                </div>
              </v-card>
            </v-col>
          </v-row>
        </v-form>

        <div class="divrow mt-6" style="gap: 10px;">
          <v-btn class="btn" style="background-color: #fff!important;"  @click="dialogNewBeneficiary = false">
            Cancel
            <img src="@/assets/sources/icons/close.svg" alt="close" style="width: 15px">
          </v-btn>
          <v-btn :loading="loadingAddBeneficiary" :disabled="!formBeneficiaryValid" class="btn" @click="addBeneficiary" style="border: none!important;">
            Add beneficiary
            <img src="@/assets/sources/icons/plus-square.svg" alt="plust-square icon">
          </v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import '@/assets/styles/pages/settings.scss'
import icpIcon from '@/assets/sources/icons/internet-computer-icon.svg'
import bankIcon from '@/assets/sources/icons/bank.svg'
import ChileIcon from '@/assets/sources/icons/CL.svg'
import { ref } from 'vue'
import { AgentCanister } from '@/repository/agent-canister'
import { AuthClientApi } from '@/repository/auth-client-api'
import { closeLoader, fileCompression, getImageArrayBuffer, getUrlFromFile as getUrlFromFileFunc, showLoader } from '@/plugins/functions'
import { useToast } from 'vue-toastification'
import variables from '@/mixins/variables'
import { UserProfileModel } from '@/models/user-profile-model'

export default{
  setup(){
      const toast = useToast(),
      { globalRules, beneficiaryUrl, countries } = variables,
      getUrlFromFile = getUrlFromFileFunc,
      tabsWindow = ref(1),
      show_password= ref(false),
      dialogResetPassword= ref(false),
      dialogCompany= ref(false),
      dialogBankTransferDetails= ref(false),
      dialogSelectPayment= ref(false),
      walletStatus= ref(false),
      status2fa= ref(false),
      verifyStatus= ref(false),
      dialogParticipantForm= ref(false),
      dialogPending= ref(false),
      dialogParticipant= ref(false),
      dialogPhone= ref(false),
      items= ["US", "UK"],
      selectedLang= ref('USA'),
      dialogConect= ref(false),
      dialogCreditCrad= ref(false),
      dialog2fa= ref(false),
      dialogBeneficiary= ref(false),
      dialogNewBeneficiary= ref(false),
      dialogDeleteAccount = ref(false),

      dataBanks = ref([]),
      payments = [
        {
          key: 'bank',
          icon: bankIcon,
          name: "Bank Transfer",
          width: 50
        },
        {
          key: 'icp',
          icon: icpIcon,
          name: "Payment with ICP",
          width: 40
        },
      ],
      formBeneficiaryRef = ref(),
      formBeneficiaryValid = ref(false),
      formBeneficiary = ref({
        search: null,
        beneficiary: null,
        beneficiaries: null,
      }),
      beneficiaries = ref(null),
      loadingSearchBeneficiary = ref(false),
      loadingAddBeneficiary = ref(false),
      profileCompanyLogo = ref(null),
      formProfileRef = ref(),
      loadingFormProfile = ref(false),
      formProfile = ref({
        companyId: null,
        companyName: null,
        companyLogo: [],
        country: null,
        city: null,
        address: null,
        email: null,
      })

    return{
      beneficiaryUrl,
      getUrlFromFile,
      globalRules,
      toast,
      tabsWindow,
      show_password,
      dialogResetPassword,
      dialogCompany,
      dialogBankTransferDetails,
      dialogSelectPayment,
      walletStatus,
      status2fa,
      verifyStatus,
      dialogParticipantForm,
      dialogPending,
      dialogParticipant,
      dialogPhone,
      items,
      selectedLang,
      dialogConect,
      dialogCreditCrad,
      dialog2fa,
      dialogBeneficiary,
      dialogNewBeneficiary,
      dialogDeleteAccount,
      dataBanks,
      payments,
      formBeneficiaryRef,
      formBeneficiaryValid,
      formBeneficiary,
      beneficiaries,
      loadingSearchBeneficiary,
      loadingAddBeneficiary,
      countries,
      profileCompanyLogo,
      formProfileRef,
      loadingFormProfile,
      formProfile,
    }
  },
  computed: {
    profile() {
      return UserProfileModel.get()
    }
  },
  mounted() {
    if (this.$route.query.editProfile) {
      this.$router.replace('/settings')
      this.dialogCompany = true
    }

    this.getData()
  },

  methods:{
    async getData() {
      this.profileCompanyLogo = this.profile.companyLogo

      this.formProfile.companyName = this.profile.companyName
      this.formProfile.companyId = this.profile.companyId
      this.formProfile.city = this.profile.city
      this.formProfile.country = this.profile.country
      this.formProfile.address = this.profile.address
      this.formProfile.email = this.profile.email

      await this.getBeneficiaries()
    },
    async searchBeneficiaries() {
      if (!this.formBeneficiary.search || this.loadingSearchBeneficiary) return
      this.loadingSearchBeneficiary = true

      try {
        this.formBeneficiary.beneficiaries = await AgentCanister.filterUsers(this.formBeneficiary.search)
      } catch (error) {
        this.toast.error(error)
      }

      this.loadingSearchBeneficiary = false
    },
    async addBeneficiary() {
      if (!(await this.formBeneficiaryRef.validate()).valid || this.loadingAddBeneficiary) return
      this.loadingAddBeneficiary = true

      try {
        await AgentCanister.requestBeneficiary(this.formBeneficiary.beneficiary)
        this.dialogNewBeneficiary = false
        for (const key of Object.keys(this.formBeneficiary)) this.formBeneficiary[key] = null
        this.toast.success("Beneficiary request sent")
      } catch (error) {
        this.toast.error(error)
      }

      this.loadingAddBeneficiary = false
    },
    async getBeneficiaries() {
      try {
        this.beneficiaries = await AgentCanister.getBeneficiaries()
      } catch (error) {
        this.beneficiaries = []
        this.toast.error(error)
      }
    },
    onConnectPayment(item) {
      switch (item.key) {
        case 'bank': {
          this.dialogSelectPayment = false;
          this.dialogBankTransferDetails = true
        } break;
        case 'icp': {
          this.dialogSelectPayment = false;
        } break;
      }
    },
    async getUserId() {
      try {
        const principal = await AuthClientApi.getPrincipal()
        principal.toString().copyToClipboard(`User ID ${principal.toString()} copied to clipboard`)
      } catch (error) {
        this.toast.error(error);
      }
    },
    async getBeneficiaryProfile(uid, index) {
      this.formBeneficiary.beneficiary = uid

      if (this.formBeneficiary.beneficiaries[index].loading || this.formBeneficiary.beneficiaries[index].companyLogo) return;
      this.formBeneficiary.beneficiaries[index].loading = true

      try {
        const profile = await AgentCanister.getProfile(uid)
        this.formBeneficiary.beneficiaries[index].companyLogo = profile.companyLogo
      } catch (error) {
        this.toast.error(error)
      }

      this.formBeneficiary.beneficiaries[index].loading = false
    },
    async saveProfileInfo() {
      if (this.loadingFormProfile || !(await this.formProfileRef.validate()).valid) return
      this.loadingFormProfile = true

      try {
        await AgentCanister.updateUserInfo(this.formProfile)
        this.toast.success("Company information updated!")
      } catch (error) {
        this.toast.error(error.toString())
      }

      this.loadingFormProfile = false
      this.dialogCompany = false;
    },
    async deleteAccount() {
      showLoader()

      try {
        await AgentCanister.deleteUser()
        closeLoader()
        this.$router.push('/auth/login')
        this.toast.success("Account deleted");
      } catch (error) {
        closeLoader()
        this.toast.error(error);
      }
    }
  }
}

</script>