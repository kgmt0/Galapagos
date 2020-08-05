window.RactiveBlockPreview = EditForm.extend({

  data: () -> {
    block:     undefined # NetTangoBlock
    code:      undefined # String
  }

  on: {

    # (Context) => Unit
    'render': (_) ->
      console.log("block-preview render")
      block = @get("block")

      if not block.id?
        block.id = 0

      defs = {
        version: 5
        height: 300
        width: 400
        expressions: NetTangoBlockDefaults.expressions
      }

      sample = {
        id: block.id + 1,
        action: "Preview Command",
        format: 'show "hello!"',
        required: false
      }

      if block.builderType? and block.builderType is "Procedure"
        chain        = { x: 5, y: 5, blocks: [ block ] }
        defs.blocks  = [ block, sample ]
        defs.program = { chains: [ chain ] }

      else
        proc = {
          id: block.id + 1,
          action: "Preview Proc",
          required: true,
          placement: NetTango.blockPlacementOptions.starter,
          format: "to preview",
          limit: 1
        }
        chain = { x: 5, y: 5, blocks: [ proc, block ] }
        defs.blocks = [ proc, sample, block ]
        defs.program = { chains: [ chain ] }

      try
        NetTango.init("NetLogo", @containerId, defs, NetTangoRewriter.formatDisplayAttribute)
      catch ex
        # hmm, what to do with an error, here?
        console.log(ex)
        return

      NetTango.onProgramChanged(@containerId, (ntContainerId, event) => @updateNetLogoCode())
      @updateNetLogoCode()

      return

  }

  containerId: "ntb-block-preview-canvas"

  resetNetTango: () ->
    block = @get("block")
    defs  = NetTango.save(@containerId)
    defs.blocks = defs.blocks.map( (b) -> if b.id is block.id then block else b )

    try
      NetTango.init("NetLogo", @containerId, defs, NetTangoRewriter.formatDisplayAttribute)
    catch ex
      # hmm, what to do with an error, here?
      console.log(ex)
      return

    @updateNetLogoCode()

    return

  updateNetLogoCode: () ->
    code = NetTango.exportCode(@containerId).trim()
    @set("code", code)
    return

  components: {

  }

  template:
    """
    <div class="ntb-block-preview">

    <div>Preview</div>

    <textarea id="ntb-block-preview-code" class="ntb-code" readOnly>{{ code }}</textarea>

    <div id="ntb-block-preview" class="ntb-canvas">
      <div id="ntb-block-preview-canvas" />
    </div>

    </div>
    """
})
