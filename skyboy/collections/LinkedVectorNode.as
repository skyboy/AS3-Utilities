package skyboy.collections {
	/**
	 *   A node in a linked list. Its purpose is to hold the data in the
	 *   node as well as links to the previous and next nodes.
	 *   @author Jackson Dunstan
	 *   @author skyboy
	 */
	public class LinkedVectorNode {
		public var next:LinkedVectorNode;
		public var prev:LinkedVectorNode;
		public var data:*;
		internal var data2:*;
		public function LinkedVectorNode(data:* = null, next:LinkedVectorNode = null, prev:LinkedVectorNode = null) {
			this.data = data;
			this.next = next;
			this.prev = prev;
		}
		public function clone(next:LinkedVectorNode = null, prev:LinkedVectorNode = null):LinkedVectorNode {
			return new LinkedVectorNode(data, next, prev);
		}
	}
}
