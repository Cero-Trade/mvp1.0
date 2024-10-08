<template>
  <div class="v-img-input">
    <v-file-input
      v-model:model-value="model"
      variant="solo-filled"
      :accept="accept"
      :prepend-inner-icon="prependInnerIcon"
      :prepend-icon="prependIcon"
      :append-inner-icon="appendInnerIcon"
      :append-icon="appendIcon"
      :rules="rules"
      :error="error"
      :error-messages="errorMessages"
      :messages="messages"
      :max-errors="maxErrors"
      :bg-color="bgColor"
      :base-color="baseColor"
      :class="{ fullWidth, 'v-input--empty': !model?.length }"
      :style="`
        --height: ${isOnlyDigits(height) ? `${height}px` : height};
        --max-height: ${isOnlyDigits(maxHeight) ? `${maxHeight}px` : maxHeight};
        --max-width: ${isOnlyDigits(maxWidth) ? `${maxWidth}px` : maxWidth};
        --min-height: ${isOnlyDigits(minHeight) ? `${minHeight}px` : minHeight};
        --min-width: ${isOnlyDigits(minWidth) ? `${minWidth}px` : minWidth};
        --width: ${isOnlyDigits(width) ? `${width}px` : width};
        ${!!sizes ? `--sizes: ${isOnlyDigits(sizes) ? `${sizes}px` : sizes};` : ''}
        --border-radius: ${isOnlyDigits(rounded) ? `${rounded}px` : rounded};
        --border: ${border};
        --label-align: ${labelAlign};
      `"
      @change="event => {
        const files = event.target.files

        src = getUrlFromFile(files[0])
        emit('update:modelValue', files)
      }"
    >
      <template #label>
        <slot name="label">{{ label }}</slot>
      </template>

      <template #append>
        <slot name="append" />
      </template>

      <template #selection>
        <v-chip rounded="100px" class="v-img-input__length-chip">{{ formatBytes(model[0].size) }}</v-chip>

        <v-img
          :src="src"
          :alt="alt ?? 'image preview of selector'"
          :width="sizes ?? width"
          :max-width="maxWidth"
          :min-width="minWidth"
          :height="sizes ?? height"
          :max-height="maxHeight"
          :min-height="minHeight"
          :content-class="contentClass"
          :cover="cover"
          :eager="eager"
          :gradient="gradient"
          :options="options"
          :transition="transition"
          :inline="inline"
          :lazy-src="lazySrc"
        />
      </template>
    </v-file-input>
  </div>
</template>

<script setup>
import { ref, watch, onBeforeMount, computed } from 'vue'
import { getUrlFromFile, getFileFromUrl, isOnlyDigits, formatBytes } from '@/plugins/functions'

const
  props = defineProps({
  accept: {
    type: String,
    default: 'image/*'
  },
  modelValue: [String, FileList, File],
  prependInnerIcon: String,
  prependIcon: String,
  appendInnerIcon: String,
  appendIcon: String,
  alt: String,
  aspectRatio: Number,
  contentClass: String,
  cover: Boolean,
  eager: Boolean,
  gradient: String,
  height: String,
  maxHeight: String,
  maxWidth: String,
  minHeight: String,
  minWidth: String,
  sizes: String,
  width: String,
  options: Object,
  transition: String,
  inline: Boolean,
  lazySrc: String,
  rounded: String,
  border: String,
  rules: Array,
  errorMessages: [Array, String],
  error: Boolean,
  messages: String,
  maxErrors: Number,
  bgColor: String,
  baseColor: String,
  fullWidth: Boolean,
  label: String,
  labelAlign: String,
}),
modelValue = computed(() => props.modelValue),
emit = defineEmits(['update:modelValue']),

model = ref(),
src = ref()


watch(modelValue, getData)
onBeforeMount(() => {
  if (!modelValue.value) return
  getData(modelValue.value)
})

async function getData(value) {
  if (typeof value !== 'string') return

  const file = await getFileFromUrl(value)

  src.value = value
  model.value = [file]
}
</script>

<style lang="scss">
.v-img-input {
  position: relative;

  &__length-chip {
    position: absolute !important;
    right: 5px !important;
    bottom: 5px !important;
    z-index: 2;
    background-color: hsl(0, 0%, 96%) !important;

    .v-chip__underlay { opacity: .3 !important }
    .v-chip__content { color: #000 !important }
  }

  .v-input {

    &__control {
      width: var(--sizes, var(--width));
      max-width: var(--sizes, var(--max-width));
      min-width: var(--sizes, var(--min-width));
      height: var(--sizes, var(--height));
      max-height: var(--sizes, var(--max-height));
      min-height: var(--sizes, var(--min-height));
    }
    
    .v-field {
      border-radius: var(--border-radius);
      border: var(--border);
      padding: 0;

      &__input {
        height: 100%;
        padding: 0;
      }

      &__field > .v-label {
        top: 50% !important;
        transform: translateY(-50%) !important;
        min-width: 100% !important;
        margin: 0 !important;
        font-size: 16px !important;
      }

      .v-label { opacity: 0 }
    }

    &--empty .v-field .v-label { opacity: 1 }


    &.fullWidth {
      .v-field__clearable {
        position: absolute;
        inset: 0;
      }
    }

    .v-img {
      width: var(--sizes, var(--width));
      max-width: var(--sizes, var(--max-width));
      min-width: var(--sizes, var(--min-width));
      height: var(--sizes, var(--height));
      max-height: var(--sizes, var(--max-height));
      min-height: var(--sizes, var(--min-height));
      border-radius: var(--border-radius);
    }
  }
}
</style>
